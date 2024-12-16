from flask import Flask
from flasgger import Swagger
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_mail import Mail
from sqlalchemy.orm import DeclarativeBase
from celery import Celery

from config import Config
from .errors import handle_exception


class Base(DeclarativeBase):
    pass


db = SQLAlchemy(model_class=Base)
migrate = Migrate()
mail = Mail()
celery = Celery(__name__, broker=Config.CELERY_BROKER_URL)


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    swagger = Swagger(app)
    
    db.init_app(app)
    migrate.init_app(app, db)
    mail.init_app(app)

    celery.conf.update(app.config)
    
    from app.models import user, group, token, category, food, recipe, meal_plan, role, login_attempt, shopping, unit, fridge_item
    
    from .controllers.user import user_api
    app.register_blueprint(user_api, url_prefix="/api/user")
    
    from .controllers.admin import admin_api
    app.register_blueprint(admin_api, url_prefix="/api/admin")
    
    from .controllers.fridge import fridge_api
    app.register_blueprint(fridge_api, url_prefix="/api/fridge")
    
    from .controllers.shopping import shopping_api
    app.register_blueprint(shopping_api, url_prefix="/api/shopping")

    from .controllers.recipe import recipe_api
    app.register_blueprint(recipe_api, url_prefix="/api/recipe")
    
    app.register_error_handler(Exception, handle_exception)

    return app