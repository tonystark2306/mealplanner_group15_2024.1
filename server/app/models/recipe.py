from sqlalchemy import String, Text, DateTime, ForeignKey, Table, Column, CheckConstraint, Float, Integer, Boolean, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base
from uuid import uuid4
from typing import Optional

from .meal_plan import meal_plan_recipes

# Move recipe_foods table here
recipe_foods = Table(
    'recipe_foods',
    Base.metadata,
    #dèaut integer
    Column('id', String(36), primary_key=True, default=lambda: str(uuid4())),
    Column('recipe_id', String(36), ForeignKey('recipes.id'), primary_key=True, nullable=False),
    Column('food_id', String(36), nullable=True),
    Column('food_name', String(255), nullable=True),
    Column('unit_id', String(36), nullable=True),
    Column('unit_name', String(50), nullable=True),
    Column('quantity', Float, nullable=False, default=0.0),
    UniqueConstraint('recipe_id', 'food_name', name='uq_recipe_food')   
)

class Recipe(Base):
    __tablename__ = 'recipes'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    dish_name: Mapped[str] = mapped_column(String(100), nullable=False)  # Name of the recipe
    cooking_time: Mapped[Optional[float]] = mapped_column(Float, nullable=True)  # Cooking time of the recipe, tính bằng phút
    content_html: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # HTML content of the recipe
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # Description of the recipe
    type: Mapped[Optional[str]] = mapped_column(String(50), nullable=True, default='custom')  # Type of the recipe: custom, system
    group_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey('groups.id'), nullable=True)  # Group who created the recipe, if
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)  # Timestamp for when the recipe was created
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)  # Timestamp for when the recipe was last updated
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)  # Flag to indicate if the recipe is deleted

    groups = relationship('Group', backref='recipes')
    images = relationship('RecipeImage', back_populates='recipe')
    meal_plans = relationship('MealPlan', secondary=meal_plan_recipes, back_populates='recipes', cascade='all, delete')

    def __init__(self, group_id, dish_name, cooking_time, content_html, description, **kwargs):
        self.dish_name = dish_name
        self.cooking_time = cooking_time
        self.content_html = content_html
        self.description = description
        self.group_id = group_id
        if not group_id:
            self.type = 'system'
        else:
            self.group_id = group_id
            self.type = 'custom'


    @property
    def foods(self):
        from app import db
        result = (
            db.session.query(recipe_foods)
            .filter(recipe_foods.c.recipe_id == self.id)
            .all()
        )
        return [dict(
            id=r.id, recipe_id=r.recipe_id,
            food_id=r.food_id, food_name=r.food_name, 
            unit_id=r.unit_id, unit_name=r.unit_name, 
            quantity=r.quantity) for r in result]
    
        

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}
    



class RecipeImage(Base):
    __tablename__ = 'recipe_images'
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    recipe_id: Mapped[str] = mapped_column(String(36), ForeignKey('recipes.id'),  nullable=False)
    order: Mapped[int] = mapped_column(Integer, nullable=False)  # Order of the image
    image_url: Mapped[str] = mapped_column(Text, nullable=False)  # URL or path to the image
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)  # Timestamp for when the image was added
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)  # Timestamp for when the image was last updated
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)  # Flag to indicate if the image is deleted

    recipe = relationship('Recipe', back_populates='images')

    def __init__(self, recipe_id, image_url, order):
        self.recipe_id = recipe_id
        self.image_url = image_url
        self.order = order

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}