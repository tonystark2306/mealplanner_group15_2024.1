from datetime import datetime, timezone, timedelta
import jwt
import logging
import random

from werkzeug.security import check_password_hash

from ...repository.user_repository import UserRepository
from ...repository.token_repository import TokenRepository
from config import secret_key


user_repository = UserRepository()
token_repository = TokenRepository()


def validate_login(email, password):
    """Validate the login credentials of an user."""
    user = user_repository.get_user_by_email(email)

    if not user or not check_password_hash(user.password_hash, password):
        return None
    
    return user


def generate_access_token(user_id, expires_in=600):
    """Generate a new access token for the user."""
    try:
        payload = {
            "user_id": user_id,
            "exp":  datetime.now(tz=timezone.utc) + timedelta(seconds=expires_in)
        }
        new_access_token = jwt.encode(payload, secret_key, algorithm="HS256")
        return new_access_token
    
    except jwt.PyJWTError as e:
        logging.error(f"JWT Error: {str(e)}")
        raise

    except Exception as e:
        logging.error(f"Error generating access token: {str(e)}")
        raise


def generate_refresh_token(user_id, expires_in=2592000): 
    """Generate a new refresh token for the user."""
    try:
        payload = {
            "user_id": user_id,
            "exp":  datetime.now(tz=timezone.utc) + timedelta(seconds=expires_in)
        }
        new_refresh_token = jwt.encode(payload, secret_key, algorithm="HS256")
        token_repository.save_new_refresh_token(user_id, new_refresh_token)
        return new_refresh_token
    
    except jwt.PyJWTError as e:
        logging.error(f"JWT Error: {str(e)}")
        raise

    except Exception as e:
        logging.error(f"Error generating access token: {str(e)}")
        raise