from datetime import datetime as dt, timezone, timedelta
import jwt

from werkzeug.security import check_password_hash
from app import db
from ..models.user import User
from ..repository.user_repository import UserRepository



user_repo = UserRepository()

def validate_login(email, password):
    user = db.session.execute(
        db.select(User).where(User.email == email)
    ).scalar_one_or_none()

    if user is None:
        return None

    if not check_password_hash(user.password_hash, password):
        return None
    
    return user


# def generate_access_token(user_id, expires_in=600):
#     payload = {
#         "user_id": user_id,
#         "exp":  dt.now(tz=timezone.utc) + timedelta(seconds=expires_in)
#     }
#     token = jwt.encode(payload, secret_key, algorithm="HS256")
#     return token


# def generate_refresh_token(user_id, expires_in=2592000): 
#     payload = {
#         "user_id": user_id,
#         "exp":  dt.now(tz=timezone.utc) + timedelta(seconds=expires_in)
#     }
#     token = jwt.encode(payload, secret_key, algorithm="HS256")
#     return token


def is_email_registered(email):
    user= user_repo.get_user_by_email(email)
    
    if user:
        print(user.email)
        return True
    return False


def save_new_user(email, password, name, language, timezone, deviceId):
    new_user = user_repo.save_new_user(email, password, name, language, timezone, deviceId)
    return new_user
    



def generate_confirm_token(user_id):
    secret_key = "my_meal"
    payload = {
        "user_id": user_id,
        "exp": dt.utcnow() + timedelta(hours=24)  # Thay vì dt.timedelta, dùng timedelta đã import sẵn
    }
    token = jwt.encode(payload, secret_key, algorithm="HS256")
    return token