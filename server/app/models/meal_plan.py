
from sqlalchemy import String, Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from .base import Base

class MealPlan(Base):
    __tablename__ = 'meal_plans'
    
    plan_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    group_id: Mapped[int] = mapped_column(Integer, ForeignKey('groups.group_id'), nullable=False)
    food_id: Mapped[int] = mapped_column(Integer, ForeignKey('foods.food_id'), nullable=False)
    schedule_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    meal_type: Mapped[str] = mapped_column(String(50), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Define relationships
    group = relationship('Group', backref='meal_plans')
    food = relationship('Food', backref='meal_plans')

    def __init__(self, group_id, food_id, schedule_time, meal_type):
        self.group_id = group_id
        self.food_id = food_id
        self.schedule_time = schedule_time
        self.meal_type = meal_type

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}