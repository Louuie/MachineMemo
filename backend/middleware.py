from flask import request, redirect, jsonify, session
from supabase import create_client, ClientOptions
from functools import wraps
import os

# Initialize Supabase client
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_KEY, options=ClientOptions(flow_type="pkce"))

def get_user_settings(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        user_id = request.args.get("user_id")  # Get user_id from request arguments
        if not user_id:
            return {"status": "error", "message": "Missing user_id in request"}, 400

        try:
            # Query Supabase for settings
            response = supabase.table("settings").select("*").eq("user_id", user_id).execute()
            data = response.data  # Extract data

            # Format the data
            formatted_results = {
                "status": "success",
                "data": [
                    {
                        "id": item.get("id"),
                        "user_id": item.get("user_id"),
                        "machine_id": item.get("machine_id"),
                        "seat_height": item.get("seat_height"),
                        "other_setting": item.get("other_setting"),
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
        print(session.get('user_session'))
        user_sess = session.get('user_session')
        print(user_sess)

        if not name:
            return {"status": "error", "message": "Missing machine name in request"}, 400
        if not machine_type:
            return {"status": "error", "message": "Missing machine type in request"}, 400
        if not brand:
            return {"status": "error", "message": "Missing machine brand in request"}, 400
        try:
            data = supabase.table("machines").insert({"name": name, "type": machine_type, "brand": brand}).execute()
            assert len(data.data) > 0
            request.middleware_data = {"status": "success", "message": "successfully added machine to db"}
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
            response = supabase.auth.sign_in_with_oauth(
                {
                    "provider": "google",
                    "options": {
                        "redirect_to": "http://3.101.59.11:5001/callback" 
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
            "access_token": auth.session.access_token,
            "refresh_token": auth.session.refresh_token,
            "expires_at": auth.session.expires_at,
            "user_id": auth.user.id
            }
            print(session.get('user_session'))
            session.modified = True
            return redirect("http://3.101.59.11:5001/get_session")
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}
            return jsonify(request.middleware_data), 500

    return wrapper
def get_session(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        user_sess = session.get('user_session')
        print(user_sess)
        if not user_sess:
            return jsonify({"status": "error", "message": "Missing user_session please login first"}), 400
        sess = {
            "access_token": user_sess['access_token'],
            "refresh_token": user_sess['refresh_token'],
            "expires_at": user_sess['expires_at'],
            "user_id": user_sess['user_id']
        }
        request.middleware_data = sess
        return func(*args, **kwargs)
    return wrapper


        



