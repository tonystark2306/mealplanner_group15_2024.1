from flask import Flask
from celery import Celery
from config import Config
from flask_mail import Mail
from flask_login import LoginManager
from .models.base import db
from .models.user import User

mail = Mail()
celery = Celery(__name__)  # Initialize without broker

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    db.init_app(app)
    mail.init_app(app)
    
    # Configure celery with the broker URL from config
    celery.conf.update(
        broker_url=app.config['CELERY_BROKER_URL'],
        result_backend=app.config.get('CELERY_RESULT_BACKEND')
    )
    celery.conf.update(app.config)
    
    login_manager = LoginManager()
    login_manager.init_app(app)
    login_manager.login_view = 'auth.login'
    
    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(user_id)
    
    class ContextTask(celery.Task):
        def __call__(self, *args, **kwargs):
            with app.app_context():
                return self.run(*args, **kwargs)
    
    celery.Task = ContextTask
    
    from .controllers.user import user_api
    app.register_blueprint(user_api, url_prefix="/user")

    with app.app_context():
        db.create_all()

    return app