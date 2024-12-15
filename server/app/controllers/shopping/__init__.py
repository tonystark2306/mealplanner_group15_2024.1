from flask import Blueprint

shopping_api = Blueprint("shopping_api", __name__)

from . import shopping_controller, task_controller