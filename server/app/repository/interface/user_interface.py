from abc import ABC, abstractmethod
from ...models.user import User as UserModel


class UserInterface(ABC):
    def __init__(self):
        pass

    @abstractmethod
    def get_user_by_email(self, email) -> UserModel:
        pass