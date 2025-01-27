import supabase
from flask import request, session
from functools import wraps
def get_user_settings(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        machine_id = request.args.get("machine_id")
        # user_session = session.get('user_session')
        # if not user_session:
        #     return {"status": "error", "message": "Missing user_session in request"}, 400

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