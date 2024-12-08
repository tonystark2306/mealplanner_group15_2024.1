from .. import db

from .interface.shopping_list_interface import ShoppingListInterface
from ..models.shopping import ShoppingList as ShoppingListModel


class ShoppingListRepository(ShoppingListInterface):
    def __init__(self):
        pass

    # def get_shopping_by_id(self, shopping_id):
    #     return ShoppingListModel.query.filter_by(id=shopping_id).first()

    # def get_shopping_by_user_id(self, user_id):
    #     return ShoppingListModel.query.filter_by(user_id=user_id).all()

    def add_shopping_list(self, shopping_list):
        new_list = ShoppingListModel(name=shopping_list['name'], 
                                     group_id=shopping_list['group_id'], 
                                     assigned_to=shopping_list['assigned_to'], 
                                     notes=shopping_list['notes'], 
                                     due_date=shopping_list['due_date'])
        

        db.session.add(new_list)
        db.session.commit()
        return new_list

    # def update_shopping_list(self, shopping_list):
    #     db.session.commit()
    #     return shopping_list

    # def delete_shopping_list(self, shopping_list):
    #     db.session.delete(shopping_list)
    #     db.session.commit()
    #     return shopping_list