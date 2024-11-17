from uuid import uuid4  # Add this import
from sqlalchemy import String, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from .base import Base

class RefreshToken(Base):
    __tablename__ = 'refresh_tokens'

    # Remove token_id field and add id field
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    refresh_token: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    is_revoked: Mapped[bool] = mapped_column(Boolean, default=False)

    # Define relationship
    user = relationship('User', backref='refresh_tokens')

    def __init__(self, user_id, refresh_token, expires_at):
        self.id = str(uuid4())  # Initialize id with UUID
        self.user_id = user_id
        self.refresh_token = refresh_token
        self.expires_at = expires_at

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}
