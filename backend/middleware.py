from flask import request, redirect, jsonify, session
from supabase import create_client, ClientOptions
from functools import wraps
import os
import datetime

# Initialize Supabase client
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_KEY, options=ClientOptions(flow_type="pkce"))
# No need for environment variable for this
baseURl = "http://192.168.1.29:5001"

def get_user_settings(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        machine_id = request.args.get("machine_id")

        try:
            # Query Supabase for settings
            response = supabase.table("settings").select("*").eq("machine_id", machine_id).execute()
            data = response.data

            # Format timestamp in PostgreSQL timestamptz format
            # current_time = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S.%f%z")
            # data = supabase.table("settings").update({"last_used": current_time}).eq("id", setting_id).execute()
            
            # Update last_used timestamp for these settings
            current_time = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S.%f%z")
            for item in data:
                supabase.table("settings").update({"last_used": current_time}).eq("id", item.get("id")).execute()

            # Format the data to match Swift struct
            formatted_results = {
                "status": "success",
                "data": [
                    {
                        "id": item.get("id"),
                        "user_id": item.get("user_id"),
                        "machine_id": item.get("machine_id"),
                        "settings": item.get("settings", {}).get("settings", {})
                    }
                    for item in data
                ],
            }

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
        
        if not settings:
            return {"status": "error", "message": "Missing settings in request"}, 400
            
        # Format timestamp in PostgreSQL timestamptz format
        current_time = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S.%f%z")
        machine_settings = {
            "machine_id": machine_id,
            "settings": settings,
            "last_used": current_time
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

            # Update the settings directly
            data = supabase.table("settings").update({"settings": updated_settings}).eq("id", setting_id).execute()
            print(f"DEBUG: Supabase response: {data}")
            
            assert len(data.data) > 0
            request.middleware_data = {
                "status": "success", 
                "message": "Successfully updated machine setting",
                "data": {
                    "id": data.data[0].get("id"),
                    "user_id": data.data[0].get("user_id"),
                    "machine_id": data.data[0].get("machine_id"),
                    "settings": data.data[0].get("settings")
                }
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

def get_user_machines(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            # Get all settings with their last_used timestamps
            settings = supabase.table("settings").select("machine_id,last_used").order("last_used", desc=True).execute()
            
            if not settings.data:
                request.middleware_data = {"status": "success", "data": []}
                return func(*args, **kwargs)

            # Get unique machine_ids, preserving order of most recently used
            seen = set()
            machine_ids = [item['machine_id'] for item in settings.data if item['machine_id'] not in seen and not seen.add(item['machine_id'])]
            
            if not machine_ids:
                request.middleware_data = {"status": "success", "data": []}
                return func(*args, **kwargs)
            
            # Get machine details for those ids
            machines = supabase.table("machines").select("*").in_("id", machine_ids).execute()
            
            # Create a mapping of machine_id to last_used time
            last_used_map = {item['machine_id']: item['last_used'] for item in settings.data}
            
            # Sort machines by their most recent last_used time
            sorted_machines = sorted(
                machines.data,
                key=lambda m: last_used_map.get(m['id']) or "",
                reverse=True
            )
            
            # Format the response
            result = [
                {
                    "id": machine['id'],
                    "name": machine['name'],
                    "brand": machine['brand'],
                    "type": machine['type']
                }
                for machine in sorted_machines
            ]
            
            request.middleware_data = {
                "status": "success",
                "data": result
            }
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}
        return func(*args, **kwargs)
    return wrapper

