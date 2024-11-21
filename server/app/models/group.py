from uuid import uuid4
from sqlalchemy import Double, String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base

class Group(Base):
    __tablename__ = 'groups'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    group_name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    admin_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Add relationship to admin
    admin = relationship('User', foreign_keys=[admin_id])

    def __init__(self, user_id, group_name):
        self.admin_id = user_id
        self.group_name = group_name

    def to_json(self):
        return {
            'id': self.id,
            'group_name': self.group_name,
            'admin_id': self.admin_id,
            'created_at': str(self.created_at)
        }

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}

class GroupMember(Base):
    __tablename__ = 'group_members'
    
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), primary_key=True)
    group_id: Mapped[str] = mapped_column(String(36), ForeignKey('groups.id'), primary_key=True)
    joined_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user = relationship('User', backref='group_members')
    group = relationship('Group', backref='group_members')

    def __init__(self, user_id, group_id):
        self.user_id = user_id
        self.group_id = group_id

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}
    
class FridgeItem(Base):
    __tablename__ = 'fridge_items'
    
    group_id: Mapped[str] = mapped_column(String(36), ForeignKey('groups.id'), primary_key=True)
    food_id:Mapped[str] = mapped_column(String(36), ForeignKey('foods.id'), primary_key=True)
    quantity: Mapped[int] = mapped_column(Double, nullable=False)
    expiration_date: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    group = relationship('Group', backref='fridge_items')
    food = relationship('Food', backref='fridge_items')

    def __init__(self, group_id, food_id, quantity, expiration_date):
        self.group_id = group_id
        self.food_id = food_id
        self.quantity = quantity
        self.expiration_date = expiration_date

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}
    