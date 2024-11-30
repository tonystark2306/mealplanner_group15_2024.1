from sqlalchemy import String, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from datetime import datetime
from app import db, Base
from uuid import uuid4

class Unit(Base):
    __tablename__ = 'units'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    name: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    def __init__(self, name):
        self.name = name

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}