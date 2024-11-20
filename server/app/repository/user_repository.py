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