import logging
from ...repository.user_repository import UserRepository


class UserService:
    def __init__(self):
        self.user_repository = UserRepository()
        
        
    def deactivate_user_account(self, user):
        try:
            self.user_repository.deactivated_user(user)
        except Exception as e:
            logging.error(f"Error deactivating account user: {str(e)}")
            raise