from flask import Flask
from flasgger import Swagger
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_mail import Mail
from sqlalchemy.orm import DeclarativeBase
from celery import Celery

from config import Config
from .errors import handle_exception


swagger_template = {
    "swagger": "2.0",
    "info": {
        "title": "👨‍🍳 Meal Planner API 🍴",
        "description": "API documentation for the Meal Planner system.\nMade with 🧡 by Group 15 - IT4788 - K66 - HUST",
        "version": "1.0.0"
    },
    "host": "localhost:5000",  
    "schemes": ["http"],
    "tags": [
        {
            "name": "User - Auth",
            "description": "Endpoints for user authentication, login, register, and token management."
        },
        {
            "name": "User - Edit",
            "description": "Endpoints for editing user profiles, including password changes and personal information updates."
        },
        {
            "name": "User - Group",
            "description": "Endpoints for managing user groups, including creating, editing, and retrieving groups."
        },
        {
            "name": "User",
            "description": "General user-related endpoints such as profile retrieval and account deletion."
        },
        {
            "name": "Admin - Category",
            "description": "Administrative endpoints for managing categories in the system, including creation, updates, and deletion."
        },
        {
            "name": "Admin - Unit",
            "description": "Administrative endpoints for managing measurement units in the system."
        },
        {
            "name": "Food",
            "description": "Endpoints for managing food items, including creation, updates, and deletion."
        }
    ]
}


class Base(DeclarativeBase):
    pass


db = SQLAlchemy(model_class=Base)
migrate = Migrate()
mail = Mail()
celery = Celery(__name__, broker=Config.CELERY_BROKER_URL)


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    swagger = Swagger(app, template=swagger_template)
    CORS(app, resources={r"/*": {
        "origins": "*", 
        "methods": ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
        "allow_headers": "*",
        "expose_headers": "*"
    }})
    
    db.init_app(app)
    migrate.init_app(app, db)
    mail.init_app(app)

    celery.conf.update(app.config)
    
    from app.models import user, group, token, category, food, recipe, meal_plan, role, login_attempt, shopping, unit, fridge_item
    
    from .controllers.user import user_api
    app.register_blueprint(user_api, url_prefix="/api/user")
    
    from .controllers.admin import admin_api
    app.register_blueprint(admin_api, url_prefix="/api/admin")
    
    from .controllers.food import food_api
    app.register_blueprint(food_api, url_prefix="/api/food")
    
    from .controllers.fridge import fridge_api
    app.register_blueprint(fridge_api, url_prefix="/api/fridge")
    
    from .controllers.shopping import shopping_api
    app.register_blueprint(shopping_api, url_prefix="/api/shopping")

    from .controllers.meal import meal_api
    app.register_blueprint(meal_api, url_prefix="/api/meal")

    from .controllers.recipe import recipe_api
    app.register_blueprint(recipe_api, url_prefix="/api/recipe")
    
    app.register_error_handler(Exception, handle_exception)

    return app