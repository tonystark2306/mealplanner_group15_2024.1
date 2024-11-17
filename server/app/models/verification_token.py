
from sqlalchemy import String, Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from .base import Base
from uuid import uuid4

class VerificationToken(Base):
    __tablename__ = 'verification_tokens'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    token: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Define relationship
    user = relationship('User', backref='verification_tokens')

    def __init__(self, user_id, token, expires_at):
        self.user_id = user_id
        self.token = token 
        self.expires_at = expires_at

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}