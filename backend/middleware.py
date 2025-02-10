from flask import request, redirect, jsonify, session
from supabase import create_client, ClientOptions
from functools import wraps
import os

# Initialize Supabase client
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_KEY, options=ClientOptions(flow_type="pkce"))
# No need for environment variable for this
baseURl = "http://3.101.59.11:5001"

def get_user_settings(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        machine_id = request.args.get("machine_id")

        try:
            # Query Supabase for settings
            response = supabase.table("settings").select("*").eq("machine_id", machine_id).execute()
            data = response.data  # Extract data

            # Format the data
            formatted_results = {
                "status": "success",
                "data": [
                    {
                        "id": item.get("id"),
                        "user_id": item.get("user_id"),
                        "machine_id": item.get("machine_id"),
                        # Flatten the settings structure
                        "settings": item.get("settings", {}).get("settings", {})
                    }
                    for item in data
                ],
            }


            # Attach to request object for downstream use
            request.middleware_data = formatted_results
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}

        return func(*args, **kwargs)
    return wrapper
def get_machines(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        machine_type = request.args.get("type")
        if not machine_type:
            return {"status": "error", "message": "Missing machine type in request"}, 400
        # Make sure the enter a type that actually exists
        # if machine_type != "Official" or "User":
        #     return {"status": "error", "message": "machine_type needs to be Official or User"}, 400


        try:
            # Query supabase for machines
            response = supabase.table("machines").select("*").eq("type", machine_type).execute()
            data = response.data

            # Format the results
            formatted_results = {
                "status": "success",
                "data": [
                    {
                        "id": item.get("id"),
                        "name": item.get("name"),
                        "type": item.get("type"),
                        "brand": item.get("brand")
                    }
                    for item in data
                ],
            }
            request.middleware_data = formatted_results
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}
        return func(*args, **kwargs)
    return wrapper
def add_machines(func):
    @wraps (func)
    def wrapper(*args, **kwargs):
        name = request.args.get("name")
        machine_type = request.args.get("type")
        brand = request.args.get("brand")
        user_sess = session.get('user_session')

        if not name:
            return {"status": "error", "message": "Missing machine name in request"}, 400
        if not machine_type:
            return {"status": "error", "message": "Missing machine type in request"}, 400
        if not brand:
            return {"status": "error", "message": "Missing machine brand in request"}, 400
        try:
            data = supabase.table("machines").insert({"name": name, "type": machine_type, "brand": brand}).execute()
            assert len(data.data) > 0
            machine_id = data.data[0].get("id")
            request.middleware_data = {"status": "success", "message": "successfully added machine to db", "id": machine_id}
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}
        return func(*args, **kwargs)
    return wrapper
def add_machine_settings(func):
    @wraps (func)
    def wrapper(*args, **kwargs):
        machine_id = request.args.get("machine_id")
        user_session = session.get('user_session')      
        settings = request.get_json()
        # TODO: Add Error handlers for the query parameters 
        # if not user_session or 'access_token' not in user_session:
        #     return {"status": "error", "message": "Missing user_id in request, please login"}, 400
        if not settings:
            return {"status": "error", "message": "Missing settings in request"}, 400
        machine_settings = {
            "machine_id": machine_id,
            "settings": settings,
        }
        try:
            data = supabase.table("settings").insert(machine_settings).execute()
            assert len(data.data) > 0
            request.middleware_data = {"status": "success", "message": "successfully added machine setting to db"}
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}
        return func(*args, **kwargs)
    return wrapper
    
def login_with_google(func):
    @wraps (func)
    def wrapper(*args, **kwargs):
        try:
            # Redirect user to Google login
            print(f"AWSIP?? {baseURl}")
            response = supabase.auth.sign_in_with_oauth(
                {
                    "provider": "google",
                    "options": {
                        "redirect_to": baseURl + "/callback" 
                    },
                }
            )
            request.middleware_data = response.url  # URL for Google login
            print("Taking you to the Google Login Page...")
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}
        return func(*args, **kwargs)
    return wrapper

def callback(func):
    @wraps (func)
    def wrapper(*args, **kwargs):
        code = request.args.get("code")
        next_url = request.args.get("next", "http://127.0.0.1:5001/")
        if not code:
            return jsonify({"status": "error", "message": "Missing authorization code"}), 400

        try:
            auth = supabase.auth.exchange_code_for_session({"auth_code": code})
            session['user_session'] = {
            "user_data": {
                "name": auth.session.user.user_metadata.get('name'),
                "email": auth.session.user.user_metadata.get('email'),
                "profile_picture:": auth.user.user_metadata.get('avatar_url'),
            },
            "access_token": auth.session.access_token,
            "refresh_token": auth.session.refresh_token,
            "expires_at": auth.session.expires_at,
            "user_id": auth.user.id
            }
            session.modified = True
            print("Taking you to the callback app?")
            return redirect("myapp://callback")
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}
            return jsonify(request.middleware_data), 500

    return wrapper
def logout(func):
    wraps(func)
    def wrapper(*args, **kwargs):
        # Sign the user out
        logout_response = supabase.auth.sign_out()
        print(f"logout_response: {logout_response}")
        request.middleware_data = {
            "status": "success"
        }
        return func(*args, **kwargs)
    return wrapper
def update_setting(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        machine_id = request.args.get("machine_id")
        setting_id = request.args.get("setting_id")
        updated_settings = request.get_json()
        
        print(f"DEBUG: Received setting_id: {setting_id}")
        print(f"DEBUG: Received updated settings: {updated_settings}")
        
        if not setting_id:
            return {"status": "error", "message": "Missing setting_id in request"}, 400
        if not updated_settings:
            return {"status": "error", "message": "Missing updated settings in request"}, 400
        try:
            current_settings = supabase.table("settings").select("*").eq("id", setting_id).execute()
            if len(current_settings.data) == 0:
                return {"status": "error", "message": "Setting not found!"}, 404

            existing_machine_id = current_settings.data[0].get("machine_id")

            # Restructure the settings JSON to match required format
            formatted_settings = {
                "settings": {
                    "settings": updated_settings,
                    "machine_id": existing_machine_id,
                }
            }
            
            print(f"DEBUG: Formatted settings payload: {formatted_settings}")
        
            data = supabase.table("settings").update(formatted_settings).eq("id", setting_id).execute()
            print(f"DEBUG: Supabase response: {data}")
            
            assert len(data.data) > 0
            request.middleware_data = {
                "status": "success", 
                "message": "Successfully updated machine setting",
                "data": data.data[0]
            }
        except Exception as e:
            print(f"DEBUG: Error in update_setting: {str(e)}")
            request.middleware_data = {"status": "error", "message": str(e)}
        return func(*args, **kwargs)
    return wrapper

def user(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        response = supabase.auth.get_user().user.user_metadata
        request.middleware_data = {
            "email": response.get('email'),
            "name": response.get('name'),
            "profile_picture": response.get('avatar_url')
        }
        return func(*args, **kwargs)
    return wrapper


        