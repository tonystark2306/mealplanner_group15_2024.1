from flask import Blueprint

meal_api = Blueprint("meal_api", __name__)

from . import meal_controller