import logging
from ...repository.user_repository import UserRepository


class UserService:
    def __init__(self):
        self.user_repository = UserRepository()
        
        
    def delete_user_from_db(self, user):
        try:
            self.user_repository.delete_user(user)
        except Exception as e:
            logging.error(f"Error deleting user from the database: {str(e)}")
            raise