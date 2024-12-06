import logging

from ...repository.group_repository import GroupRepository, GroupMemberRepository
from ...repository.user_repository import UserRepository


class GroupService:
    def __init__(self):
        self.group_repository = GroupRepository()
        self.group_member_repository = GroupMemberRepository()
        self.user_repository = UserRepository()
        
    
    def list_groups_of_user(self, user_id):
        groups = self.group_repository.list_groups_of_user(user_id)
        return [group.to_json() for group in groups]    
       
        
    def get_group_by_id(self, group_id):
        return self.group_repository.get_group_by_id(group_id)
    
    
    def get_user_by_username(self, username):
        return self.user_repository.get_user_by_username(username)
    
    
    def list_members_of_group(self, group_id):
        group_members = self.group_member_repository.get_all_members_of_group(group_id)
        return [member.to_json() for member in group_members]
    
    
    def save_new_group(self, admin_id, group_name, member_usernames):
        try:
            group = self.group_repository.create_group(admin_id, group_name)
            self.group_member_repository.add_member(admin_id, group.id)
            if member_usernames:
                for username in member_usernames:
                    user = self.user_repository.get_user_by_username(username)
                    self.group_member_repository.add_member(user.id, group.id)
                    
            return group
        
        except Exception as e:
            logging.error(f"Error saving new group into database: {str(e)}")
            raise
        
    
    def is_member_of_group(self, user_id, group_id):
        group_member = self.group_member_repository.get_group_member(user_id, group_id)
        return group_member is not None
    
    
    def add_members_to_group(self, group_id, member_usernames):
        try:
            for username in member_usernames:
                user = self.user_repository.get_user_by_username(username)
                self.group_member_repository.add_member(user.id, group_id)
        except Exception as e:
            logging.error(f"Error adding members to group: {str(e)}")
            raise
        
        
    def remove_member_from_group(self, user_id, group_id):
        try:
            self.group_member_repository.remove_member(user_id, group_id)
        except Exception as e:
            logging.error(f"Error removing member from group: {str(e)}")
            raise