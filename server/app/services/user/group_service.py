import logging

from ...repository.group_repository import GroupRepository, GroupMemberRepository
from ...repository.user_repository import UserRepository


class GroupService:
    def __init__(self):
        self.group_repository = GroupRepository()
        self.group_member_repository = GroupMemberRepository()
        self.user_repository = UserRepository()
    
    
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