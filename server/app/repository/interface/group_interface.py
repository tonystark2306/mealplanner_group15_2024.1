from abc import ABC, abstractmethod
from ...models.group import Group as GroupModel


class GroupInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def create_group(self, admin_id, group_name) -> GroupModel:
        pass
    
    
class GroupMemberInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def add_member(self, user_id, group_id):
        pass