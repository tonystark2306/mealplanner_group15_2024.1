from uuid import uuid4
from sqlalchemy import String, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base, db
from typing import Optional


class LoginAttempt(Base):
    __tablename__ = 'login_attempts'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    attempt_time: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    ip_address: Mapped[str] = mapped_column(String(45))
    status: Mapped[str] = mapped_column(String(50), nullable=False)  # success, failed, locked_out
    user_agent: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    is_remembered: Mapped[bool] = mapped_column(Boolean, default=False)  # Flask-Login remember me flag
    
    # Define relationship
    user = relationship('User', backref='login_attempts')

    def __init__(self, user_id, ip_address, status, user_agent=None, is_remembered=False):
        self.user_id = user_id
        self.ip_address = ip_address
        self.status = status
        self.user_agent = user_agent
        self.is_remembered = is_remembered

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}

    @classmethod
    def log_login_attempt(cls, user_id, ip_address, status, user_agent=None, is_remembered=False):
        #ghi vào db
        log_attempt = LoginAttempt(
            user_id=user_id,
            ip_address=ip_address,
            status=status,
            user_agent=user_agent,
            is_remembered=is_remembered
        )
        db.session.add(log_attempt)
        db.session.commit()
        return cls().save(log_attempt)