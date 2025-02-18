from functools import wraps
from flask import request, jsonify, session, redirect
from supabase_client import supabase  # Use the shared Supabase client
import datetime
def get_user_settings(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        machine_id = request.args.get("machine_id")
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            request.middleware_data = {"status": "error", "message": "No authorization token provided"}
            return func(*args, **kwargs)

        #   Extract Bearer Token
        token = auth_header.replace("Bearer ", "").strip()
        if not token:
            request.middleware_data = {"status": "error", "message": "Invalid authorization token"}
            return func(*args, **kwargs)

        #   Get the User ID from Supabase Session
        auth_response = supabase.auth.get_user(token)
        if not auth_response or not auth_response.user:
            request.middleware_data = {"status": "error", "message": "User authentication failed"}
            return func(*args, **kwargs)

        user_id = auth_response.user.id

        try:
            response = supabase.table("settings").select("*").eq("machine_id", machine_id).eq("user_id", user_id).execute()
            print(f"get user setting res {response}")
            data = response.data

            # Update `last_used` timestamps
            current_time = datetime.datetime.now(datetime.timezone.utc).isoformat()
            for item in data:
                supabase.table("settings").update({"last_used": current_time}).eq("id", item.get("id")).execute()

            request.middleware_data = {
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

        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}

        return func(*args, **kwargs)
    return wrapper

def update_setting(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        #   Extract Machine ID & Setting ID
        machine_id = request.args.get("machine_id")
        setting_id = request.args.get("setting_id")
        updated_settings = request.get_json()

        print(f"DEBUG: Received machine_id: {machine_id}")
        print(f"DEBUG: Received setting_id: {setting_id}")
        print(f"DEBUG: Received updated settings: {updated_settings}")

        #   Validate Request Data
        if not setting_id:
            return {"status": "error", "message": "Missing setting_id in request"}, 400
        if not updated_settings:
            return {"status": "error", "message": "Missing updated settings in request"}, 400

        #   Extract Authorization Token
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return {"status": "error", "message": "No authorization token provided"}, 401
        
        token = auth_header.split("Bearer ")[-1].strip()
        if not token:
            return {"status": "error", "message": "Invalid authorization token"}, 401

        #   Authenticate User with Supabase
        auth_response = supabase.auth.get_user(token)
        if not auth_response or not auth_response.user:
            return {"status": "error", "message": "User authentication failed"}, 401
        
        user_id = auth_response.user.id
        print(f"DEBUG: Authenticated user_id: {user_id}")

        try:
            #   Check if Setting Exists
            current_settings = supabase.table("settings").select("*").eq("id", setting_id).eq("user_id", user_id).execute()
            if len(current_settings.data) == 0:
                return {"status": "error", "message": "Setting not found or unauthorized!"}, 404

            existing_machine_id = current_settings.data[0].get("machine_id")

            #   Format Settings JSON Correctly
            formatted_settings = {
                "settings": {
                    "settings": updated_settings,
                    "machine_id": existing_machine_id,
                    "last_used": datetime.datetime.utcnow().isoformat()  # Add timestamp
                }
            }

            print(f"DEBUG: Formatted settings payload: {formatted_settings}")

            #   Update in Supabase (RLS ensures only the owner can modify)
            data = supabase.table("settings").update(formatted_settings).eq("id", setting_id).eq("user_id", user_id).execute()
            print(f"DEBUG: Supabase response: {data}")

            #   Ensure Update Worked
            if not data.data:
                return {"status": "error", "message": "Failed to update settings!"}, 500

            #   Store Response in Middleware Data
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



def get_machines(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        machine_type = request.args.get("type")
                #   Extract Authorization Token
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return {"status": "error", "message": "No authorization token provided"}, 401
        
        token = auth_header.split("Bearer ")[-1].strip()
        if not token:
            return {"status": "error", "message": "Invalid authorization token"}, 401

        #   Authenticate User with Supabase
        auth_response = supabase.auth.get_user(token)
        if not auth_response or not auth_response.user:
            return {"status": "error", "message": "User authentication failed"}, 401
        
        
        if not machine_type:
            return jsonify({"status": "error", "message": "Missing machine type in request"}), 400

        try:
            response = supabase.table("machines").select("*").eq("type", machine_type).execute()
            data = response.data

            request.middleware_data = {
                "status": "success",
                "data": [
                    {"id": item.get("id"), "name": item.get("name"), "type": item.get("type"), "brand": item.get("brand")}
                    for item in data
                ],
            }

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
        #   Extract Authorization Token
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return {"status": "error", "message": "No authorization token provided"}, 401
        
        token = auth_header.split("Bearer ")[-1].strip()
        if not token:
            return {"status": "error", "message": "Invalid authorization token"}, 401

        #   Get the User ID from Supabase Session
        auth_response = supabase.auth.get_user(token)
        if not auth_response or not auth_response.user:
            request.middleware_data = {"status": "error", "message": "User authentication failed"}
            return func(*args, **kwargs)
        user_id = auth_response.user.id

        
        if not settings:
            return {"status": "error", "message": "Missing settings in request"}, 400
            
        # Format timestamp in PostgreSQL timestamptz format
        current_time = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S.%f%z")
        machine_settings = {
            "machine_id": machine_id,
            "settings": settings,
            "last_used": current_time,
            "user_id": user_id
        }
        
        try:
            data = supabase.table("settings").insert(machine_settings).execute()
            print(f"data: {data}")
            assert len(data.data) > 0
            request.middleware_data = {"status": "success", "message": "successfully added machine setting to db"}
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}
        return func(*args, **kwargs)
    return wrapper


def add_machines(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        print(f"auth_header {auth_header}")
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': 'No token provided'}), 401
        
        token = auth_header.split(' ')[1]


        name = request.args.get("name")
        machine_type = request.args.get("type")
        brand = request.args.get("brand")

        if not name or not machine_type or not brand:
            return jsonify({"status": "error", "message": "Missing required machine details"}), 400

        try:
            user_response = supabase.auth.get_user(token)
            user_id = user_response.user.id  # Ensure the request is made for the correct user

            data = supabase.table("machines").insert({
                "name": name,
                "type": machine_type,
                "brand": brand,
                "user_id": user_id  # Associate machine with the logged-in user
            }).execute()

            request.middleware_data = {
                "status": "success",
                "message": "Machine added",
                "id": data.data[0]["id"]
            }

        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}

        return func(*args, **kwargs)
    return wrapper



def get_user_machines(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            #   Get the Auth Token from the Request Header
            auth_header = request.headers.get("Authorization")
            if not auth_header:
                request.middleware_data = {"status": "error", "message": "No authorization token provided"}
                return func(*args, **kwargs)

            #   Extract Bearer Token
            token = auth_header.split("Bearer ")[-1].strip()
            if not token:
                request.middleware_data = {"status": "error", "message": "Invalid authorization token"}
                return func(*args, **kwargs)

            #   Get the User ID from Supabase Session
            auth_response = supabase.auth.get_user(token)
            if not auth_response or not auth_response.user:
                request.middleware_data = {"status": "error", "message": "User authentication failed"}
                return func(*args, **kwargs)

            user_id = auth_response.user.id
            print(f"✅ Authenticated User ID: {user_id}")

            #   Fetch User-Specific Settings (RLS filters data automatically)
            settings_response = supabase.table("settings").select("machine_id, last_used").eq("user_id", user_id).order("last_used", desc=True).execute()
            settings = settings_response.data

            if not settings:
                request.middleware_data = {"status": "success", "data": []}
                return func(*args, **kwargs)

            #   Get Unique Machine IDs
            seen = set()
            machine_ids = [item["machine_id"] for item in settings if item["machine_id"] not in seen and not seen.add(item["machine_id"])]

            if not machine_ids:
                request.middleware_data = {"status": "success", "data": []}
                return func(*args, **kwargs)

            #   Fetch Machines Owned by User (RLS ensures they belong to the user)
            machines_response = supabase.table("machines").select("*").in_("id", machine_ids).execute()
            machines = machines_response.data

            #   Map last_used timestamps to each machine
            last_used_map = {item["machine_id"]: item["last_used"] for item in settings}

            #   Sort Machines by Last Used Timestamp
            sorted_machines = sorted(
                machines,
                key=lambda m: last_used_map.get(m["id"]) or "",
                reverse=True
            )

            #   Format Response
            request.middleware_data = {
                "status": "success",
                "data": [
                    {"id": machine["id"], "name": machine["name"], "brand": machine["brand"], "type": machine["type"]}
                    for machine in sorted_machines
                ]
            }

        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}

        return func(*args, **kwargs)
    return wrapper
