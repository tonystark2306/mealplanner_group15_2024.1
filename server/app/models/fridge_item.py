
from uuid import uuid4
from sqlalchemy import Double, String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base

class FridgeItem(Base):
    __tablename__ = 'fridge_items'
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    owner_id: Mapped[str] = mapped_column(String(36), nullable=False)
    added_by: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    food_id:Mapped[str] = mapped_column(String(36), ForeignKey('foods.id'), primary_key=True)
    quantity: Mapped[int] = mapped_column(Double, nullable=False)
    expiration_date: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    status: Mapped[str] = mapped_column(String(10), default='active')


    food = relationship('Food', backref='fridge_items')
    user = relationship('User', backref='fridge_items')


    def __init__(self, owner_id, food_id, user_id, quantity, expiration_date, created_at=None, updated_at=None, status=None):
        self.owner_id = owner_id
        self.added_by = user_id
        self.food_id = food_id
        self.quantity = quantity
        self.expiration_date = expiration_date
        self.created_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
        self.status = 'active'


    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}
    

    def to_json(self):
        return {
            'id': self.id,
            'ownerId': self.owner_id,
            'addedBy': self.added_by,
            'foodId': self.food_id,
            'quantity': self.quantity,
            'expirationDate': str(self.expiration_date),
            'createdAt': str(self.created_at)
        }