
from sqlalchemy import String, Text, DateTime, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from uuid import uuid4
from .base import Base

class ShoppingList(Base):
    __tablename__ = 'shopping_lists'
    
    id: Mapped[int] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    group_id: Mapped[str] = mapped_column(String(36), ForeignKey('groups.id'), primary_key=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    assigned_username: Mapped[str] = mapped_column(String(100), nullable=True)
    notes: Mapped[str] = mapped_column(Text, nullable=True)
    due_date: Mapped[datetime] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    group = relationship('Group', backref='shopping_lists')
    tasks = relationship('ShoppingTask', backref='shopping_list', lazy=True)

    def __init__(self, name, group_id,  assigned_username=None, notes=None, due_date=None):
        self.name = name
        self.group_id = group_id
        self.assigned_username = assigned_username
        self.notes = notes
        self.due_date = due_date

class ShoppingTask(Base):
    __tablename__ = 'shopping_tasks'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    list_id: Mapped[int] = mapped_column(String(36), ForeignKey('shopping_lists.id'), nullable=False)
    food_id: Mapped[str] = mapped_column(String(36), ForeignKey('foods.id'), nullable=False)
    quantity: Mapped[str] = mapped_column(String(50), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    food = relationship('Food', backref='tasks')

    def __init__(self, list_id, food_id, quantity):
        self.list_id = list_id
        self.food_id = food_id
        self.quantity = quantity