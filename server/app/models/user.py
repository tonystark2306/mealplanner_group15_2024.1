import uuid
from typing import Optional
from sqlalchemy import String, Integer, Boolean, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from werkzeug.security import generate_password_hash
from datetime import datetime
from app import db, Base
from flask_login import UserMixin

class User(UserMixin, Base):
    
    __tablename__ = 'users'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    username: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    language: Mapped[str] = mapped_column(String(10), default='en')
    timezone: Mapped[str] = mapped_column(String(50))
    deviceId: Mapped[str] = mapped_column(String(255), nullable=False)
    avatar_url: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    def __init__(self, email, password, username, name, language='en', timezone=None, device_id=None, is_verified=False):
        self.email = email
        self.password_hash = generate_password_hash(password)
        self.username = username
        self.name = name
        self.language = language
        self.timezone = timezone
        self.is_verified = is_verified
        self.deviceId = device_id
    
    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}
    
    def get_id(self):
        return str(self.id)
    
    def to_json(self):
        return {
            "id": self.id,
            "email": self.email,
            "username": self.username,
            "name": self.name,
            "language": self.language,
            "timezone": self.timezone,
            "deviceId": self.deviceId,
            "avatar_url": self.avatar_url,
            "is_verified": self.is_verified
        }
    
    @property
    def is_active(self):
        return self.active  # Assume you have an 'active' column