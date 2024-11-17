from sqlalchemy import String, Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from .base import Base

class LoginAttempt(Base):
    __tablename__ = 'login_attempts'
    
    attempt_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    attempt_time: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    ip_address: Mapped[str] = mapped_column(String(45))
    status: Mapped[str] = mapped_column(String(50), nullable=False)  # success, failed, locked_out
    
    # Define relationship
    user = relationship('User', backref='login_attempts')

    def __init__(self, user_id, ip_address, status):
        self.user_id = user_id
        self.ip_address = ip_address
        self.status = status

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}