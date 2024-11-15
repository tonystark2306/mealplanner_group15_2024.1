import uuid
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column
from werkzeug.security import generate_password_hash
from .base import Base

class User(Base):
    
    __tablename__ = 'users'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    language: Mapped[str] = mapped_column(String(255), nullable=False)
    timezone: Mapped[str] = mapped_column(String(255), nullable=False)
    deviceId: Mapped[str] = mapped_column(String(255), nullable=False)

    
    def __init__(self, email, password_hash, name, language, timezone, deviceId):
        self.email = email
        self.password_hash = password_hash
        self.name = name
        self.language = language
        self.timezone = timezone
        self.deviceId = deviceId
    
    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}