from .interface.group_interface import GroupRepositoryInterface
from ..models.group import Group as GroupModel
from .. import db

class GroupRepository(GroupRepositoryInterface):
    def __init__(self):
        pass

    def add_group(self, user_id, group_name, avatar_url=""):
        try:
            group = GroupModel(
                user_id=user_id,
                group_name=group_name,
                avatar_url=avatar_url
            )
            db.session.add(group)
            db.session.commit()
            return group
        except Exception as e:
            db.session.rollback()
            print(f"Database error: {str(e)}")
            return None

    def get_group_by_id(self, group_id):
        pass

    def get_all_groups(self):
        pass

    def delete_group(self, group_id):
        pass