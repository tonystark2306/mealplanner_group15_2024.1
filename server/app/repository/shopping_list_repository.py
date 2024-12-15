from .. import db

from .interface.shopping_list_interface import ShoppingListInterface
from ..models.shopping import ShoppingList as ShoppingListModel


class ShoppingListRepository(ShoppingListInterface):
    def __init__(self):
        pass


    def get_shopping_by_id(self, shopping_id):

        _list = db.session.query(ShoppingListModel).filter(ShoppingListModel.id == shopping_id, ShoppingListModel.status != 'Deleted').first()
        return _list


    # def get_shopping_by_user_id(self, user_id):
    #     return ShoppingListModel.query.filter_by(user_id=user_id).all()


    def get_shopping_lists_by_group_id(self, group_id):
        #lấy tất cả các danh sách mua sắm của một nhóm dựa vào group_id với status != 'Cancelled'
        return db.session.query(ShoppingListModel).filter_by(group_id=group_id).filter(ShoppingListModel.status != 'Deleted').all()


    def add_shopping_list(self, shopping_list):
        new_list = ShoppingListModel(name=shopping_list.get('name') or None,
                                     group_id=shopping_list['group_id'],
                                     assigned_to=shopping_list.get('assigned_to') or None,
                                     notes=shopping_list.get('notes') or None,
                                     due_time=shopping_list.get('due_time') or None
                                     )
        
        db.session.add(new_list)
        db.session.commit()
        return new_list


    def update_shopping_list(self, shopping_list):
        _list = db.session.query(ShoppingListModel).filter(ShoppingListModel.id == shopping_list['list_id'],ShoppingListModel.status != 'Deleted').first()
        if shopping_list is not None and _list is not None:
            _list.name = shopping_list.get('new_name') or _list.name
            _list.group_id = shopping_list['group_id'] or _list.group_id
            _list.assigned_to = shopping_list.get('new_assigned_to') or _list.assigned_to
            _list.notes = shopping_list.get('new_notes') or _list.notes
            _list.due_time = shopping_list.get('new_due_time') or _list.due_time
            _list.status = shopping_list.get('new_status') or _list.status

        db.session.commit()
        return _list

    # def delete_shopping_list(self, shopping_list):
    #     db.session.delete(shopping_list)
    #     db.session.commit()
    #     return shopping_list