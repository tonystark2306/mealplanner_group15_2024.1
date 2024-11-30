from abc import ABC, abstractmethod
from ...models.user import User as UserModel


class UserInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def get_user_by_id(self, id) -> UserModel:
        pass

    @abstractmethod
    def get_user_by_email(self, email) -> UserModel:
        pass
    
    @abstractmethod
    def save_user_to_db(self, email, password, name, language, timezone, device_id) -> UserModel:
        pass
    
    @abstractmethod
    def update_verification_status(self, email) -> bool:
        pass
    
    @abstractmethod
    def update_password(self, user, new_password):
        pass
    
    @abstractmethod
    def delete_user(self, user):
        pass