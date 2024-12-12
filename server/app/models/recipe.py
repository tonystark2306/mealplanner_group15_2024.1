from sqlalchemy import String, Text, DateTime, ForeignKey, Table, Column
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base
from uuid import uuid4
from typing import Optional

# Move recipe_foods table here
recipe_foods = Table(
    'recipe_foods',
    Base.metadata,
    Column('recipe_id', String(36), ForeignKey('recipes.id'), primary_key=True),
    Column('food_id', String(36), ForeignKey('foods.id'), primary_key=True)
)

class Recipe(Base):
    __tablename__ = 'recipes'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    dish_name: Mapped[str] = mapped_column(String(100), nullable=False)  # Name of the recipe
    content_html: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # HTML content of the recipe
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # Description of the recipe
    type: Mapped[Optional[str]] = mapped_column(String(50), nullable=True, default='custom')  # Type of the recipe: custom, system
    group_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey('groups.id'), nullable=True)  # Group who created the recipe, if
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)  # Timestamp for when the recipe was created

    # Update relationship to be the owner side
    foods = relationship('Food', secondary=recipe_foods, backref='recipes')
    groups = relationship('Group', backref='recipes')

    def __init__(self, group_id, typee, dish_name, content_html, description, foods=None):
        self.dish_name = dish_name
        self.content_html = content_html
        self.description = description
        self.type = typee
        self.group_id = group_id
        if foods:
            self.foods = foods

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}