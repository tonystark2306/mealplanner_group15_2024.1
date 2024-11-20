from datetime import datetime, timezone, timedelta
import logging

from .interface.token_interface import TokenInterface
from ..models.token import Token as TokenModel
from ..models.user import User as UserModel
from .. import db


class TokenRepository(TokenInterface):
    def __init__(self):
        pass
        
        
    def save_new_refresh_token(self, user_id, new_refresh_token):
        try:
            existing_token = db.session.execute(
                db.select(TokenModel).where(TokenModel.user_id == user_id)
            ).scalar()
            
            if not existing_token:
                new_token = TokenModel(user_id=user_id, refresh_token=new_refresh_token)
                db.session.add(new_token)
            else:
                existing_token.refresh_token = new_refresh_token
        
            db.session.commit()
        
        except Exception as e:
            db.session.rollback() 
            logging.error(f"Error saving new refresh token: {str(e)}")
            raise
        
    
    def save_verification_code(self, user_id, code):
        try:
            token = db.session.execute(
                db.select(TokenModel).where(TokenModel.user_id == user_id)
            ).scalar()
            
            if not token:
                new_token = TokenModel(
                    user_id=user_id,
                    verification_code=code,
                    verification_code_expires_at=datetime.now(tz=timezone.utc) + timedelta(minutes=10),
                )
                db.session.add(new_token)
            else:
                token.verification_code = code
                token.verification_code_expires_at = datetime.now(tz=timezone.utc) + timedelta(minutes=10)
                
            db.session.commit()
        
        except Exception as e:
            db.session.rollback() 
            logging.error(f"Error saving verification code: {str(e)}")
            raise
        
        
    def save_confirm_token(self, user_id, token):
        try:
            existing_token = db.session.execute(
                db.select(TokenModel).where(TokenModel.user_id == user_id)
            ).scalar()
            
            if not existing_token:
                new_token = TokenModel(user_id=user_id, confirm_token=token)
                db.session.add(new_token)
            else:
                existing_token.confirm_token = token
                
            db.session.commit()
        
        except Exception as e:
            db.session.rollback() 
            logging.error(f"Error saving confirm token: {str(e)}")
            raise