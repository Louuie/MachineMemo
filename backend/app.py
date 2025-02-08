from flask import Flask, request, jsonify, redirect
from flask_cors import CORS
from middleware import get_user_settings, get_machines, add_machines, add_machine_settings, login_with_google, callback, update_setting, user
from datetime import timedelta
import os

def create_app():
    app = Flask(__name__)
   # Session configuration
    app.config.update(
        SECRET_KEY=os.getenv('FLASK_SECRET_KEY', 'dev_key'),
        PERMANENT_SESSION_LIFETIME=timedelta(days=7),
        SESSION_COOKIE_SECURE=False,
        SESSION_COOKIE_HTTPONLY=True,
        SESSION_COOKIE_SAMESITE='None'
    )
    
    # Configure CORS
    CORS(app, 
         supports_credentials=True,
         resources={
             r"/*": {
                 "origins": "*",
                 "methods": ["GET", "POST", "PUT", "OPTIONS"],
                 "allow_headers": ["Content-Type", "Authorization"]
             }
         })
    @app.route("/user", methods=['GET'], endpoint='get_user_middleware_endpoint')
    @user
    def get_user():
        user_data = request.middleware_data
        print(user_data)
        return jsonify({"status": "success", "data": user_data}), 200
    @app.route("/settings", methods=['GET'], endpoint='get_machine_settings_middleware_endpoint')
    @get_user_settings
    def get_settings():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500
    @app.route("/settings", methods=['POST'], endpoint='add_settings_middleware_endpoint')
    @add_machine_settings
    def add_settings():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500
    
    @app.route("/edit", methods=['PUT'], endpoint='update_settings_middleware_endpoint')
    @update_setting
    def update_settings():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500
    
    @app.route('/machines', methods=['GET'], endpoint='machines_middleware_endpoint')
    @get_machines
    def machines_middleware():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500
    @app.route('/machines', methods=['POST'], endpoint='add_machines_middleware_endpoint')
    @add_machines
    def add_machines_middleware():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500
    @app.route('/google/login', methods=['GET'], endpoint='google_login_middleware_endpoint')
    @login_with_google
    def signin_with_google():
        middleware_url = request.middleware_data
        print("Middleware_url", middleware_url)
        return redirect(middleware_url)  # Redirects user to Google login

    @app.route('/callback', methods=['GET'], endpoint='callback_middleware_endpoint')
    @callback
    def handle_callback():
        pass
    return app

    # https://flask.palletsprojects.com/en/stable/quickstart/
    # pip install flask
    # pip install supabase
    # flask --app app.py run --host=0.0.0.0 --port=5001