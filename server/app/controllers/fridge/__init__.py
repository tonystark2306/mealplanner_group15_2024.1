from flask import Blueprint

fridge_api = Blueprint("fridge_api", __name__)

from . import frigde_controller