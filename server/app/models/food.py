
from sqlalchemy import String, Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from .base import Base

class Food(Base):
    __tablename__ = 'foods'
    
    food_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    category_id: Mapped[int] = mapped_column(Integer, ForeignKey('categories.category_id'), nullable=False)
    unit_id: Mapped[int] = mapped_column(Integer, ForeignKey('units.unit_id'), nullable=False)
    image_url: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Define relationships
    category = relationship('Category', backref='foods')
    unit = relationship('Unit', backref='foods')

    def __init__(self, name, category_id, unit_id, image_url=None):
        self.name = name
        self.category_id = category_id
        self.unit_id = unit_id
        self.image_url = image_url

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}