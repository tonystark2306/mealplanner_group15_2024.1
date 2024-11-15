import os
from dotenv import load_dotenv
from pathlib import Path


env_path = Path("server") / ".env"
load_dotenv(dotenv_path=env_path)


class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "secret_key")
    
    # Celery Configuration
    CELERY_BROKER_URL = 'redis://localhost:6379/0'
    CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'

    POSTGRESQL_USERNAME = os.environ.get("POSTGRESQL_USERNAME")
    POSTGRESQL_PASSWORD = os.environ.get("POSTGRESQL_PASSWORD")
    POSTGRESQL_HOST = os.environ.get("POSTGRESQL_HOST", "localhost")
    POSTGRESQL_PORT = os.environ.get("POSTGRESQL_PORT", "5432")
    POSTGRESQL_DBNAME = os.environ.get("POSTGRESQL_DBNAME")
    SQLALCHEMY_DATABASE_URI = (
        os.environ.get("DATABASE_URL") or
        f"postgresql://{POSTGRESQL_USERNAME}:{POSTGRESQL_PASSWORD}@{POSTGRESQL_HOST}:{POSTGRESQL_PORT}/{POSTGRESQL_DBNAME}"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    MAIL_SERVER = "smtp.gmail.com"
    MAIL_PORT = 587
    MAIL_USE_TLS = True
    MAIL_USE_SSL = False
    MAIL_USERNAME = os.environ.get("MAIL_USERNAME")
    MAIL_PASSWORD = os.environ.get("MAIL_PASSWORD")
    MAIL_DEFAULT_SENDER = ""
    MAIL_SUBJECT_PREFIX = "[Meal Planner]"
    

secret_key = Config.SECRET_KEY