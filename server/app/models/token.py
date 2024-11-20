from typing import Optional
from uuid import uuid4
from sqlalchemy import String, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import db

class Token(db.Model):
    __tablename__ = 'tokens'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    
    # Token fields
    refresh_token: Mapped[str] = mapped_column(String(255), unique=True, nullable=True)
    confirm_token: Mapped[Optional[str]] = mapped_column(String(255), unique=True, nullable=True)
    reset_token: Mapped[Optional[str]] = mapped_column(String(255), unique=True, nullable=True)
    
    # Verification token fields
    verification_code: Mapped[str] = mapped_column(String(255), unique=True, nullable=True)
    verification_code_expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=True)
    
    # Password reset token fields
    reset_code: Mapped[str] = mapped_column(String(255), unique=True, nullable=True)
    reset_code_expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=True)

    user = relationship('User', foreign_keys=[user_id])

    def __init__(self, user_id: str):
        self.user_id = user_id

    def set_refresh_token(self, token: str):
        self.refresh_token = token

    def set_verification_token(self, code: str, expires_at: datetime):
        self.verification_code = code
        self.verification_code_expires_at = expires_at

    def set_reset_code(self, token: str, expires_at: datetime):
        self.reset_code = token
        self.reset_code_expires_at = expires_at

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}