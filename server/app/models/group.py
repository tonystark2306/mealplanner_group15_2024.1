from uuid import uuid4
from sqlalchemy import Double, String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app import Base

class Group(Base):
    __tablename__ = 'groups'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    group_name: Mapped[str] = mapped_column(String(100), nullable=False)
    admin_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Add relationship to admin
    admin = relationship('User', foreign_keys=[admin_id])

    def __init__(self, admin_id, group_name):
        self.admin_id = admin_id
        self.group_name = group_name
        

    def to_json(self):
        return {
            'id': self.id,
            'groupName': self.group_name,
            'adminId': self.admin_id,
            'createdAt': str(self.created_at)
        }

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}

class GroupMember(Base):
    __tablename__ = 'group_members'
    
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), primary_key=True)
    group_id: Mapped[str] = mapped_column(String(36), ForeignKey('groups.id'), primary_key=True)
    joined_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    status: Mapped[str] = mapped_column(String(10), nullable=False, default='active')

    user = relationship('User', backref='group_members')
    group = relationship('Group', backref='group_members')

    def __init__(self, user_id, group_id):
        self.user_id = user_id
        self.group_id = group_id

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}
    
