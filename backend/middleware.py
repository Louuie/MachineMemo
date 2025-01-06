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
