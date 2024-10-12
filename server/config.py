import os
from dotenv import load_dotenv
from pathlib import Path


env_path = Path("server") / ".env"
load_dotenv(dotenv_path=env_path)

class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "secret_key")

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