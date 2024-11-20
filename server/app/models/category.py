from uuid import uuid4
from sqlalchemy import String, Integer, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import db

class Category(db.Model):
    __tablename__ = 'categories'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Add relationship
    foods = relationship('Food', secondary='food_categories', back_populates='categories')

    def __init__(self, name):
        self.name = name

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}