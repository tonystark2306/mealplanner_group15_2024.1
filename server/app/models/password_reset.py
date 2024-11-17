from uuid import uuid4
from sqlalchemy import String, Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from .base import Base

class PasswordReset(Base):
    __tablename__ = 'password_resets'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    reset_token: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Define relationship
    user = relationship('User', backref='password_resets')

    def __init__(self, user_id, reset_token, expires_at):
        self.user_id = user_id
        self.reset_token = reset_token
        self.expires_at = expires_at

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}