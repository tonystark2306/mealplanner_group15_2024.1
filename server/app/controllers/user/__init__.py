from flask import Blueprint

user_api = Blueprint("user_api", __name__)

from . import auth_controller, edit_controller, user_controller