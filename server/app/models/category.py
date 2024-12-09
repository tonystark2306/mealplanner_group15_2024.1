from uuid import uuid4
from sqlalchemy import String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base

class Category(Base):
    __tablename__ = 'categories'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    type: Mapped[str] = mapped_column(String(50), nullable=False, default='custom')  # Type of the category: custom, system
    group_id: Mapped[str] = mapped_column(String(36), ForeignKey('groups.id'), nullable=True) # Group who created the category
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Add relationship
    foods = relationship('Food', secondary='food_categories', back_populates='categories')
    group = relationship('Group', backref='categories')

    def __init__(self, name, type_1, group_id):
        self.name = name
        self.type = type_1
        self.group_id = group_id

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}