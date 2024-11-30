from sqlalchemy import String, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app import Base
from uuid import uuid4

class Role(Base):
    __tablename__ = 'roles'
    
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    role_name: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)

    def __init__(self, role_name):
        self.role_name = role_name

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}

class UserRole(Base):
    __tablename__ = 'user_roles'
    
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey('users.id'), primary_key=True)
    role_id: Mapped[str] = mapped_column(String(36), ForeignKey('roles.id'), primary_key=True)

    # Define relationships
    user = relationship('User', backref='user_roles')
    role = relationship('Role', backref='user_roles')

    def __init__(self, user_id, role_id):
        self.user_id = user_id
        self.role_id = role_id

    def as_dict(self):
        return {c.name: str(getattr(self, c.name)) for c in self.__table__.columns}