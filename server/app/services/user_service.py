from datetime import datetime, timezone, timedelta
import jwt

from werkzeug.security import check_password_hash

from app import db
from ..models.user import User
from config import secret_key


def validate_login(email, password):
    user = db.session.execute(
        db.select(User).where(User.email == email)
    )

    if user is None:
        return None
    
    if not check_password_hash(user.password_hash, password):
        return None
    
    return user


def generate_access_token(user_id, expires_in=600):
    payload = {
        "user_id": user_id,
        "exp":  datetime.now(tz=timezone.utc) + timedelta(seconds=expires_in)
    }
    token = jwt.encode(payload, secret_key, algorithm="HS256")
    return token


def generate_refresh_token(user_id, expires_in=2592000): 
    payload = {
        "user_id": user_id,
        "exp":  datetime.now(tz=timezone.utc) + timedelta(seconds=expires_in)
    }
    token = jwt.encode(payload, secret_key, algorithm="HS256")
    return token


def is_email_registered(email):
    user = db.session.execute(
        db.select(User).where(User.email == email)
    )
    
    if user:
        return True
    return False


def save_new_user(email, password, name, language, timezone, deviceId):
    new_user = User(email, password, name, language, timezone, deviceId)
    db.session.add(new_user)
    db.session.commit()
    return new_user


def generate_confirm_token(user_id, expires_in=3600):
    payload = {
        "user_id": user_id,
        "exp":  datetime.now(tz=timezone.utc) + timedelta(seconds=expires_in)
    }
    token = jwt.encode(payload, secret_key, algorithm="HS256")
    return token