from flask import Blueprint

recipe_api = Blueprint("recipe_api", __name__)

from . import recipe_controller