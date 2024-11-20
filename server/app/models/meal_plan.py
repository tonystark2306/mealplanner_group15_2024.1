from uuid import uuid4
from sqlalchemy import String, DateTime, ForeignKey, Table, Column
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import db

# New association tables
meal_plan_recipes = Table(
    'meal_plan_recipes',
    Column('plan_id', String(36), ForeignKey('meal_plans.id'), primary_key=True),
    Column('recipe_id', String(36), ForeignKey('recipes.id'), primary_key=True)
)

meal_plan_foods = Table(
    'meal_plan_foods',
    Column('plan_id', String(36), ForeignKey('meal_plans.id'), primary_key=True),
    Column('food_id', String(36), ForeignKey('foods.id'), primary_key=True)
)

class MealPlan(db.Model):
    __tablename__ = 'meal_plans'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    group_id: Mapped[str] = mapped_column(String(36), ForeignKey('groups.id'), nullable=False)
    schedule_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    meal_type: Mapped[str] = mapped_column(String(50), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Updated relationships
    group = relationship('Group', backref='meal_plans')
    recipes = relationship('Recipe', secondary=meal_plan_recipes, backref='meal_plans')
    foods = relationship('Food', secondary=meal_plan_foods, backref='meal_plans')

    def __init__(self, group_id, schedule_time, meal_type, recipes=None, foods=None):
        self.group_id = group_id
        self.schedule_time = schedule_time
        self.meal_type = meal_type
        if recipes:
            self.recipes = recipes
        if foods:
            self.foods = foods

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}