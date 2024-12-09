from abc import ABC, abstractmethod
from typing import List
from ...models.role import Role as RoleModel, UserRole as UserRoleModel


class RoleInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def get_role_by_role_name(self, role_name) -> RoleModel:
        pass
    
    @abstractmethod
    def get_role_of_user(self, user_id) -> RoleModel:
        pass
    
    @abstractmethod
    def create_role(self, role_name) -> RoleModel:
        pass
    
    
class UserRoleInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def create_user_role(self, user_id, role_id):
        pass
