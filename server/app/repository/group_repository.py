import logging

from .interface.group_interface import GroupInterface, GroupMemberInterface
from ..models.group import Group as GroupModel, GroupMember as GroupMemberModel
from .. import db


class GroupRepository(GroupInterface):
    def __init__(self):
        pass
    
    
    def create_group(self, admin_id, group_name) -> GroupModel:
        try:
            new_group = GroupModel(group_name=group_name, admin_id=admin_id)
            db.session.add(new_group)
            db.session.commit()
            return new_group
        
        except Exception as e:
            db.session.rollback() 
            logging.error(f"Error creating group: {str(e)}")
            raise
        
        
class GroupMemberRepository(GroupMemberInterface):
    def __init__(self):
        pass
    
    
    def add_member(self, user_id, group_id):
        try:
            new_member = GroupMemberModel(user_id=user_id, group_id=group_id)
            db.session.add(new_member)
            db.session.commit()
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error adding member: {str(e)}")
            raise