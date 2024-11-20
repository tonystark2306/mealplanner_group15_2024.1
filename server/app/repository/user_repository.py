import logging

from .interface.user_interface import UserInterface
from ..models.user import User as UserModel
from .. import db


class UserRepository(UserInterface):
    def __init__(self):
        pass


    def get_user_by_email(self, email) -> UserModel:
        return db.session.execute(
            db.select(UserModel).where(UserModel.email == email)
        ).scalar()
        
        
    def save_user_to_db(self, email, password, name, language, timezone, device_id) -> UserModel:
        try:
            new_user = UserModel(
                email=email,
                password=password,
                name=name,
                language=language,
                timezone=timezone,
                device_id=device_id
            )
            db.session.add(new_user)
            db.session.commit()
            return new_user
        
        except Exception as e: 
            db.session.rollback()
            logging.error(f"Error saving user to the database: {str(e)}")
            raise