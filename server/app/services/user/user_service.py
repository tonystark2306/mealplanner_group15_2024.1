import logging
from ...repository.user_repository import UserRepository


class UserService:
    def __init__(self):
        self.user_repository = UserRepository()