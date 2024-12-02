import logging
from typing import List

from .interface.group_interface import GroupInterface, GroupMemberInterface
from ..models.group import Group as GroupModel, GroupMember as GroupMemberModel
from ..models.user import User as UserModel
from .. import db


class GroupRepository(GroupInterface):
    def __init__(self):
        pass
    
    
    def get_group_by_id(self, group_id) -> GroupModel:
        return GroupModel.query.filter_by(id=group_id).first()
    
    
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
    
    
    def get_group_member(self, user_id, group_id) -> GroupMemberModel:
        return GroupMemberModel.query.filter_by(user_id=user_id, group_id=group_id).first()
    
    
    def get_all_members_of_group(self, group_id) -> List[UserModel]:
        return db.session.execute(
            db.select(UserModel)
            .join(GroupMemberModel, UserModel.id == GroupMemberModel.user_id)
            .where(GroupMemberModel.group_id == group_id)
        ).scalars().all()
            
            
    def add_member(self, user_id, group_id):
        try:
            new_member = GroupMemberModel(user_id=user_id, group_id=group_id)
            db.session.add(new_member)
            db.session.commit()
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error adding member: {str(e)}")
            raise
        
    
    def remove_member(self, user_id, group_id):
        try:
            member_to_remove = self.get_group_member(user_id, group_id)
            db.session.delete(member_to_remove)
            db.session.commit()
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error removing member: {str(e)}")
            raise