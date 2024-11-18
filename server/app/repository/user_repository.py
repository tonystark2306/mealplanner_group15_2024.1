from ..models import user
from app import db
from werkzeug.security import generate_password_hash

class UserRepository:

    @staticmethod
    def get_user_by_email(email):
        return db.session.execute(
            db.select(user.User).where(user.User.email == email)
        ).scalar_one_or_none()
    
    def save_new_user(self, email, password, name, language, timezone, deviceId):
        password_hash = generate_password_hash(password)
        new_user = user.User(email, password_hash, name, language, timezone, deviceId)
        db.session.add(new_user)
        db.session.commit()
        return new_user