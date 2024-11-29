from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_mail import Mail
from sqlalchemy.orm import DeclarativeBase
from celery import Celery

from config import Config


class Base(DeclarativeBase):
    pass


db = SQLAlchemy(model_class=Base)
migrate = Migrate()
mail = Mail()
celery = Celery(__name__, broker=Config.CELERY_BROKER_URL)


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    db.init_app(app)
    migrate.init_app(app, db)
    mail.init_app(app)
    #import tất cả các model vào đây
    from app.models import user, group, token, category, food, recipe, meal_plan, role, login_attempt, shopping, unit,fridge_item
    celery.conf.update(app.config)
    
    from .controllers.user import user_api
    app.register_blueprint(user_api, url_prefix="/user")

    return app