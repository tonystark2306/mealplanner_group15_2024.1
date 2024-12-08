from datetime import datetime

from ...repository.shopping_list_repository import ShoppingListRepository
from ...repository.user_repository import UserRepository
from ...services.user.group_service import GroupService


class ShoppingListService:
    def __init__(self):
        self.list_repo = ShoppingListRepository()
        self.user_repo = UserRepository()
        self.group_service = GroupService()


    def create_shopping_list(self, shopping_list):

        user_id = self.user_repo.get_user_by_username(shopping_list['assigned_to']).id
        if not user_id:
            return "user not found"
        
        is_member = self.group_service.is_member_of_group(user_id, shopping_list['group_id'])
        if not is_member:
            return "not a member"

        shopping_list['assigned_to'] = user_id

        shopping_list['due_date'] = datetime.strptime(shopping_list['due_date'], "%Y-%m-%d %H:%M:%S")
        return self.list_repo.add_shopping_list(shopping_list).as_dict()
