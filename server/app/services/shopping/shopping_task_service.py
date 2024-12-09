from datetime import datetime

from ...repository.shopping_list_repository import ShoppingListRepository


class ShoppingTaskService:
    def __init__(self):
        self.list_repo = ShoppingListRepository()


    def create_shopping_list(self, shopping_list):
        shopping_list['due_date'] = datetime.strptime(shopping_list['due_date'], "%Y-%m-%d %H:%M:%S")
        return self.list_repo.add_shopping_list(shopping_list)