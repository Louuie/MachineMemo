
from flask import request, session
import supabase
from functools import wraps
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