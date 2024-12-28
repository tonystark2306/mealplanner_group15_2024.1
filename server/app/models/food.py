from uuid import uuid4
from sqlalchemy import String, DateTime, ForeignKey, Column, Table
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base
from typing import Optional

food_categories = Table(
    'food_categories',
    Base.metadata,
    Column('food_id', String(36), ForeignKey('foods.id'), primary_key=True),
    Column('category_id', String(36), ForeignKey('categories.id'), primary_key=True)
)

class Food(Base):
    __tablename__ = 'foods'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    create_by: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    type: Mapped[str] = mapped_column(String(50), nullable=False, default='ingredient')
    group_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey('groups.id'), nullable=True)
    unit_id: Mapped[str] = mapped_column(String(36), ForeignKey('units.id'), nullable=False)
    image_url: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    note: Mapped[str] = mapped_column(String(255))

    # Update relationships - remove recipes relationship
    categories = relationship('Category', secondary=food_categories, back_populates='foods')
    group = relationship('Group', backref='foods')
    unit = relationship('Unit', backref='foods')
    creator = relationship('User', backref='foods', lazy=True)


    def __init__(self, user_id, name, type, group_id, category, unit_id, image_url, note):
        self.create_by = user_id
        self.name = name
        self.type = type
        self.group_id = group_id
        self.categories = [category]
        self.unit_id = unit_id
        self.image_url = image_url
        self.note = note


    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}