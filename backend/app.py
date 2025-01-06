from flask import Flask, request, jsonify
from middleware import get_user_settings

def create_app():
    app = Flask(__name__)
    @app.route("/")
    @get_user_settings
    def settings():
        middleware_data = request.middleware_data
        return jsonify(middleware_data), 200 if middleware_data["status"] == "success" else 500
    return app


    # https://flask.palletsprojects.com/en/stable/quickstart/
    # pip install flask
    # pip install supabase
    # flask --app app.py run --host=0.0.0.0 --port=5001