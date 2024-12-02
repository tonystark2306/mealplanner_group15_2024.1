from abc import ABC, abstractmethod
from ...models.token import Token as TokenModel


class TokenInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def get_token_by_user_id(self, user_id):
        pass
    
    @abstractmethod
    def save_new_refresh_token(self, user_id, new_refresh_token):
        pass
    
    @abstractmethod
    def save_verification_code(self, user_id, code):
        pass
    
    @abstractmethod
    def save_confirm_token(self, user_id, token):
        pass
    
    @abstractmethod
    def delete_refresh_token(self, user_id):
        pass