from uuid import uuid4
from sqlalchemy import String, DateTime, ForeignKey, Column, Table
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base

food_categories = Table(
    'food_categories',
    Base.metadata,
    Column('food_id', String(36), ForeignKey('foods.id'), primary_key=True),
    Column('category_id', String(36), ForeignKey('categories.id'), primary_key=True)
)

class Food(Base):
    __tablename__ = 'foods'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    create_by: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    type: Mapped[str] = mapped_column(String(50), nullable=False, default='ingredient')
    unit_id: Mapped[str] = mapped_column(String(36), ForeignKey('units.id'), nullable=False)
    image_url: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    note: Mapped[str] = mapped_column(String(255))
    status: Mapped[str] = mapped_column(String(10), nullable=False, default='active')
    # Update relationships - remove recipes relationship
    categories = relationship('Category', secondary=food_categories, back_populates='foods')
    unit = relationship('Unit', backref='foods')
    creator = relationship('User', backref='foods', lazy=True)

    def __init__(self, creator, name, typee, categories, unit_id, image_url=None, note=None):
        self.create_by = creator
        self.name = name
        self.type = typee
        self.categories = categories
        self.unit_id = unit_id
        self.image_url = image_url
        self.note = note

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}