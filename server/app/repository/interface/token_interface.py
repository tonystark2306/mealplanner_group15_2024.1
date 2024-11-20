from abc import ABC, abstractmethod
from ...models.token import Token as TokenModel


class TokenInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def save_new_refresh_token(self, user_id, new_refresh_token):
        pass