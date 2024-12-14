from uuid import uuid4
from sqlalchemy import String, DateTime, ForeignKey, Table, Column, Boolean, Float, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base

# New association tables
meal_plan_recipes = Table(
    'meal_plan_recipes',
    Base.metadata,
    Column('plan_id', String(36), ForeignKey('meal_plans.id'), primary_key=True),
    Column('recipe_id', String(36), ForeignKey('recipes.id'), primary_key=True),
    # thêm số khẩu phần mỗi món
    Column('servings', Float, nullable=False, default=1.0)
)

meal_plan_foods = Table(
    'meal_plan_foods',
    Base.metadata,
    Column('id', String(36), primary_key=True, default=lambda: str(uuid4())),
    Column('plan_id', String(36), ForeignKey('meal_plans.id'), nullable=False),
    Column('food_id', String(36), nullable=False),
    Column('food_name', String(255), nullable=False),
    Column('unit', String(50), nullable=True),
    Column('quantity', Float, nullable=False, default=0.0),
    UniqueConstraint('plan_id', 'food_name', name='uq_plan_food')
)
class MealPlan(Base):
    __tablename__ = 'meal_plans'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    group_id: Mapped[str] = mapped_column(String(36), ForeignKey('groups.id'), nullable=False)
    schedule_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    description: Mapped[str] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False)

    # Updated relationships
    group = relationship('Group', backref='meal_plans')
    recipes = relationship('Recipe', secondary=meal_plan_recipes, back_populates='meal_plans', cascade='all, delete')

    def __init__(self, group_id, name, schedule_time, description, recipes=None, foods=None):
        self.group_id = group_id
        self.schedule_time = schedule_time
        self.name = name
        self.description = description
        if recipes:
            self.recipes = recipes
        if foods:
            self.foods = foods

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}
    


    