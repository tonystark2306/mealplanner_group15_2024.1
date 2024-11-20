import logging

from .interface.token_interface import TokenInterface
from ..models.token import Token as TokenModel
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