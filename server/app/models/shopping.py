from sqlalchemy import String, Text, DateTime, ForeignKey, Integer, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from uuid import uuid4
from app import Base

class ShoppingList(Base):
    __tablename__ = 'shopping_lists'
    
    id: Mapped[int] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    group_id: Mapped[str] = mapped_column(String(36), ForeignKey('groups.id'), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    assigned_to: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=True)
    assigned_to_username: Mapped[str] = mapped_column(String(100), nullable=True)
    notes: Mapped[str] = mapped_column(Text, nullable=True)
    due_time: Mapped[datetime] = mapped_column(DateTime, nullable=True)
    status: Mapped[str] = mapped_column(
        Enum('Draft', 'Active', 'Fully Completed', 
             'Partially Completed', 'Archived', 'Cancelled', 'Deleted',
             name='shopping_list_status'), 
        nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    group = relationship('Group', backref='shopping_lists')
    tasks = relationship('ShoppingTask', backref='shopping_list', lazy=True)
    user = relationship('User', backref='shopping_lists', lazy=True)

    def __init__(self, name, group_id,  assigned_to=None, assigned_to_username=None,notes=None, due_time=None, **kwargs):
        self.name = name
        self.group_id = group_id
        self.assigned_to = assigned_to
        self.assigned_to_username = assigned_to_username
        self.notes = notes
        self.due_time = due_time
        if due_time is not None and assigned_to is not None:
            self.status = 'Active'
        else:
            self.status = 'Draft'


    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

class ShoppingTask(Base):
    __tablename__ = 'shopping_tasks'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    list_id: Mapped[str] = mapped_column(String(36), ForeignKey('shopping_lists.id'), nullable=False)
    food_id: Mapped[str] = mapped_column(String(36), ForeignKey('foods.id'), nullable=False)
    food_name: Mapped[str] = mapped_column(String(100), nullable=True)
    quantity: Mapped[str] = mapped_column(String(50), nullable=False)
    status: Mapped[str] = mapped_column(
        Enum(
        'Active',
        'Completed',
        'Cancelled',
        'Deleted',
        name='task_status'
    ), 
        nullable=False, 
        default='Active'
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    food = relationship('Food', backref='tasks')

    def __init__(self, list_id, food_id, food_name, quantity, **kwargs):
        self.list_id = list_id
        self.food_id = food_id
        self.food_name = food_name
        self.quantity = quantity

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}