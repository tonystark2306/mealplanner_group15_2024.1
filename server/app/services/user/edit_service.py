import logging
from werkzeug.security import check_password_hash
from ...repository.user_repository import UserRepository


class EditService:
    def __init__(self):
        self.user_repository = UserRepository()
    
    
    def verify_old_password(self, user, old_password):
        if not check_password_hash(user.password, old_password):
            return False
            
        return True

    
    def save_new_password(self, user, new_password):
        try:
            self.user_repository.update_password(user, new_password)
        except Exception as e:
            logging.error(f"Error saving new password: {str(e)}")
            raise