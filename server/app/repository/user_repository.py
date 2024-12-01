import logging
from werkzeug.security import generate_password_hash
from .interface.user_interface import UserInterface
from ..models.user import User as UserModel
from .. import db


class UserRepository(UserInterface):
    def __init__(self):
        pass
    
    
    def get_user_by_id(self, id) -> UserModel:
        return db.session.execute(
            db.select(UserModel).where(UserModel.id == id)
        ).scalar()


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
        
        
    def update_verification_status(self, email) -> bool:
        try:
            user = self.get_user_by_email(email)
            if not user:
                return False
            
            user.is_verified = True
            db.session.commit()
            return True
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error updating verification status: {str(e)}")
            raise
        
        
    def update_password(self, user, new_password):
        try:
            user.password = generate_password_hash(new_password)
            db.session.commit()
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error updating user password: {str(e)}")
            raise
        
        
    def update_user(self, user, data):
        try:
            for field, value in data.items():
                setattr(user, field, value)
            db.session.commit()
            
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error updating user: {str(e)}")
            raise
        
        
    def delete_user(self, user):
        try:
            db.session.delete(user)
            db.session.commit()
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error deleting user: {str(e)}")
            raise