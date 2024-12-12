from sqlalchemy import String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column
from datetime import datetime
from app import db, Base
from uuid import uuid4
from typing import Optional


class Unit(Base):
    __tablename__ = 'units'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    type: Mapped[str] = mapped_column(String(50), nullable=False, default='custom') # custom, system
    group_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey('groups.id'), nullable=True) # the custom unit was created by which group
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    group = db.relationship('Group', backref='units')

    def __init__(self, name, typee, group_id):
        self.name = name
        self.type = type
        self.group_id = group_id

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}