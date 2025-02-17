from flask import Flask, request, jsonify, redirect, session
from flask_cors import CORS
from middleware import (
    get_user_settings, get_machines, add_machines, 
    login_with_google, callback, user, logout, get_user_machines, add_machine_settings, update_setting
)
from datetime import timedelta
import os
import redis

def create_app():
    app = Flask(__name__)

    # Redis Configuration for Session Storage
    app.config.update(
        SECRET_KEY=os.getenv('FLASK_SECRET_KEY', 'dev_key'),
        PERMANENT_SESSION_LIFETIME=timedelta(days=7),
        SESSION_TYPE="redis",
        SESSION_PERMANENT=True,
        SESSION_USE_SIGNER=True,
        SESSION_KEY_PREFIX="machine_memo_",
        SESSION_REDIS=redis.StrictRedis(host="localhost", port=6379, db=0, decode_responses=False)
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

    # GET machine settings
    @app.route("/settings", methods=['GET'], endpoint='get_machine_settings_middleware_endpoint')
    @get_user_settings
    def get_settings():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500

    #ADD machine settings
    @app.route("/settings", methods=['POST'], endpoint='add_settings_middleware_endpoint')
    @add_machine_settings
    def add_settings():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500

    # UPDATE machine settings
    @app.route("/edit", methods=['PUT'], endpoint='update_settings_middleware_endpoint')
    @update_setting
    def update_settings():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500

    # list of machines
    @app.route('/machines', methods=['GET'], endpoint='machines_middleware_endpoint')
    @get_machines
    def machines_middleware():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500

    # ADD new machine
    @app.route('/machines', methods=['POST'], endpoint='add_machines_middleware_endpoint')
    @add_machines
    def add_machines_middleware():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500

    # LOGIN with Google OAuth
    @app.route('/google/login', methods=['GET'], endpoint='google_login_middleware_endpoint')
    @login_with_google
    def signin_with_google():
        middleware_url = request.middleware_data
        print("Middleware_url", middleware_url)
        return redirect(middleware_url)

    # CALLBACK route after Google OAuth
    @app.route('/callback', methods=['GET'], endpoint='callback_middleware_endpoint')
    @callback
    def handle_callback():
        pass
    # GET user info
    @app.route("/user", methods=['GET'], endpoint='get_user_middleware_endpoint')
    @user
    def get_user():
        user_data = request.middleware_data
        print(user_data)
        return jsonify({"status": "success", "data": user_data}), 200

    # LOGOUT user
    @app.route("/logout", methods=['GET'], endpoint='log_user_out_middleware_endpoint')
    @logout
    def log_user_out():
        logout = request.middleware_data
        return jsonify(logout)

    # GET user’s saved machines (sorted by last used)
    @app.route("/user/machines", methods=['GET'], endpoint='get_user_machines_middleware_endpoint')
    @get_user_machines
    def get_user_machines_endpoint():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500

    # Basic session testing route
    @app.route('/basic-page', methods=['GET'], endpoint='basic-page-endpoint')
    def basic_page():
        sess = session.get('user_session')
        print(f"Found user session: {sess}")
        return jsonify({"message": "Success", "session": sess}), 200

    return app


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    app = create_app()
    app.run(host="0.0.0.0", port=port, debug=True)
