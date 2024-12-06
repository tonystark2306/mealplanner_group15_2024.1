from abc import ABC, abstractmethod
from typing import List
from ...models.group import Group as GroupModel, GroupMember as GroupMemberModel
from ...models.user import User as UserModel


class GroupInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def list_groups_of_user(self, user_id) -> List[GroupModel]:
        pass
    
    @abstractmethod
    def get_group_by_id(self, group_id) -> GroupModel:
        pass
        
    @abstractmethod
    def create_group(self, admin_id, group_name) -> GroupModel:
        pass
    
    
class GroupMemberInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def get_group_member(self, user_id, group_id) -> GroupMemberModel:
        pass
    
    @abstractmethod
    def get_all_members_of_group(self, group_id) -> List[UserModel]:
        pass
    
    @abstractmethod
    def add_member(self, user_id, group_id):
        pass
    
    @abstractmethod
    def remove_member(self, user_id, group_id):
        pass