from flask import request
from supabase import create_client
import os

# Initialize Supabase client
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_user_settings(func):
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
                        "user_id": item.get("user_id"),
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
    def wrapper(*args, **kwargs):
        name = request.args.get("name")
        machine_type = request.args.get("type")
        brand = request.args.get("brand")
        # TODO: Add Error handlers for the query parameters 
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
    def wrapper(*args, **kwargs):
        machine_id = request.args.get("machine_id")
        user_id = request.args.get("user_id")
        settings = request.get_json()
        # TODO: Add Error handlers for the query parameters 
        if not user_id:
            return {"status": "error", "message": "Missing user_id in request"}, 400
        if not settings:
            return {"status": "error", "message": "Missing settings in request"}, 400
        machine_settings = {
            "machine_id": machine_id,
            "settings": settings,
            "user_id": user_id
        }
        try:
            data = supabase.table("settings").insert(machine_settings).execute()
            assert len(data.data) > 0
            request.middleware_data = {"status": "success", "message": "successfully added machine setting to db"}
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}
        return func(*args, **kwargs)
    return wrapper



