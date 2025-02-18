from functools import wraps
from flask import request, jsonify, session, redirect
from supabase_client import supabase  # Use the shared Supabase client
# Base URL for OAuth redirect
BASE_URL = "https://machinememo-5791cb7039d5.herokuapp.com"
def login_with_google(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            response = supabase.auth.sign_in_with_oauth(
                {
                    "provider": "google",
                    "options": {"redirect_to": BASE_URL + "/callback"},
                }
            )
            request.middleware_data = response.url  # URL for Google login
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}

        return func(*args, **kwargs)
    return wrapper


def callback(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        code = request.args.get("code")
        if not code:
            return jsonify({"status": "error", "message": "Missing authorization code"}), 400

        try:
            auth_response = supabase.auth.exchange_code_for_session({"auth_code": code})

            print("AUTH RESPONSE:", auth_response)  # Debugging output

            if not auth_response or not hasattr(auth_response, 'session') or auth_response.session is None:
                return jsonify({"status": "error", "message": "Failed to exchange code for session"}), 400

            user = auth_response.session.user
            
            # Store user session in Flask session
            session['user_session'] = {
                "user_id": user.id,
                "email": user.user_metadata.get('email'),
                "name": user.user_metadata.get('name'),
                "profile_picture": user.user_metadata.get('avatar_url'),
                "access_token": auth_response.session.access_token,
                "refresh_token": auth_response.session.refresh_token,
                "expires_at": auth_response.session.expires_at
            }
            session.modified = True  # Mark session as modified

            print("User authenticated:", session['user_session'])

            return redirect(f"machinememo://callback?access_token={auth_response.session.access_token}")

        except Exception as e:
            print(f"Callback Error: {e}")
            return jsonify({"status": "error", "message": str(e)}), 500

    return wrapper



def logout(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        # Extract Authorization Token
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
        try:
            supabase.auth.sign_out()
            session.pop('user_session', None)
            session.modified = True
            request.middleware_data = {"status": "success"}
        except Exception as e:
            request.middleware_data = {"status": "error", "message": str(e)}

        return func(*args, **kwargs)
    return wrapper


def user(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        # Get the token from Authorization header
        auth_header = request.headers.get('Authorization')
        print(f"auth_header {auth_header}")
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': 'No token provided'}), 401
        
        token = auth_header.split(' ')[1]
        
        try:
            # Get user data using the token
            user = supabase.auth.get_user(token)
            user_metadata = user.user.user_metadata
            
            request.middleware_data = {
                "email": user_metadata.get("email"),
                "name": user_metadata.get("name"),
                "profile_picture": user_metadata.get("avatar_url"),
            }
            return func(*args, **kwargs)
            
        except Exception as e:
            print(f"Auth Error: {e}")
            return jsonify({'error': 'Invalid token'}), 401
            
    return wrapper

def validate_token(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"status": "error", "message": "No token provided"}), 401

        token = auth_header.split("Bearer ")[-1].strip()
        if not token:
            return jsonify({"status": "error", "message": "Invalid token"}), 401

        try:
            auth_response = supabase.auth.get_user(token)
            if not auth_response or not auth_response.user:
                return jsonify({"status": "error", "message": "Invalid or expired token"}), 401

            request.user = auth_response.user  #   Attach user to request for later use
            return func(*args, **kwargs)

        except Exception as e:
            print(f"Token validation failed: {e}")
            return jsonify({"status": "error", "message": "Token expired"}), 401
    return wrapper
