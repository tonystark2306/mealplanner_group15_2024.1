# app/repositories/group_repository_interface.py
from abc import ABC, abstractmethod

class GroupRepositoryInterface(ABC):
    @abstractmethod
    def add_group(self, user_id: str, group_name: str, avatar_url: str = ""):
        """Create a new group"""
        pass

    @abstractmethod
    def get_group_by_id(self, group_id: str):
        """Get group by ID"""
        pass

    @abstractmethod
    def get_all_groups(self):
        """Get all groups"""
        pass

    @abstractmethod
    def delete_group(self, group_id: str):
        """Delete a group by ID"""
        pass
