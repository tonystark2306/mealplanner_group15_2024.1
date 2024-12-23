from flask import Blueprint

food_api = Blueprint("food_api", __name__)

from . import food_controller