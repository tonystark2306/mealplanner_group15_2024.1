from app.models.group import Group
from app import db



def create_group(user_id, group_name):
    """
    no params
    """
    group = Group(user_id=user_id, group_name=group_name)
    db.session.add(group)
    db.session.commit()
    return group


def get_group_by_id(group_id):
    """
    Get group by id
    :param group_id:
    :return:
    """
    return Group.query.filter_by(id=group_id).first()

def get_group_by_user_id(user_id):
    """
    Get group by user id
    :param user_id:
    :return:
    """
    return Group.query.filter_by(user_id=user_id).first()