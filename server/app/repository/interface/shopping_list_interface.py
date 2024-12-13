from abc import ABC, abstractmethod
from ...models.shopping import ShoppingList as ShoppingListModel


class ShoppingListInterface(ABC):
    def __init__(self):
        pass


    @abstractmethod
    def get_shopping_by_id(self, shopping_id):
        pass

    
    @abstractmethod
    def get_shopping_lists_by_group_id(self, group_id):
        pass


    # @abstractmethod
    # def get_list_by_user_id(self, user_id):
    #     pass


    @abstractmethod
    def add_shopping_list(self, shopping_list):
        pass


    @abstractmethod
    def update_shopping_list(self, shopping_list):
        pass


    # @abstractmethod
    # def delete_shopping_list(self, shopping_list):
    #     pass


    # @abstractmethod
    # def get_all_shopping_lists(self):
    #     pass

    