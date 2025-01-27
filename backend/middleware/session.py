from flask import request, redirect, jsonify, session
from supabase import create_client, ClientOptions 
from functools import wraps
import os
# Initialize Supabase client
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_KEY, options=ClientOptions(flow_type="pkce"))
def login_with_google(func):
    @wraps (func)
    def wrapper(*args, **kwargs):
        try:
            # Redirect user to Google login
            response = supabase.auth.sign_in_with_oauth(
                {
                    "provider": "google",
                    "options": {
                        "redirect_to": "http://192.168.1.5:5001/callback" 
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
        next_url = request.args.get("next", "http://192.168.1.5:5001/")
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
            return redirect("http://192.168.1.5:5001/get_session")
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