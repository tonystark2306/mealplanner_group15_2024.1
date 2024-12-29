from datetime import datetime

from ...repository.shopping_list_repository import ShoppingListRepository
from ...repository.user_repository import UserRepository
from ...services.user.group_service import GroupService


class ShoppingListService:
    def __init__(self):
        self.list_repo = ShoppingListRepository()
        self.user_repo = UserRepository()
        self.group_service = GroupService()


    def get_shopping_list_by_id(self, list_id):
        return self.list_repo.get_shopping_by_id(list_id).as_dict()


    def create_shopping_list(self, shopping_list):
        if shopping_list.get('assigned_to'):
            user = self.user_repo.get_user_by_username(shopping_list['assigned_to'])
            if not user:
                return "user not found"
            user_id = user.id
            is_member = self.group_service.is_member_of_group(user_id, shopping_list['group_id'])
            if not is_member:
                return "not a member"
            
            shopping_list['assigned_to_username'] = shopping_list['assigned_to']
            shopping_list['assigned_to'] = user_id

        if shopping_list.get('due_time'):
            shopping_list['due_time'] = datetime.strptime(shopping_list['due_time'], "%Y-%m-%d %H:%M:%S")
        return self.list_repo.add_shopping_list(shopping_list).as_dict()


    def update_shopping_list(self, shopping_list):

        if shopping_list.get('new_assigned_to'):
            user = self.user_repo.get_user_by_username(shopping_list['new_assigned_to'])
            if not user:
                return "user not found"
            user_id = user.id
            if not self.group_service.is_member_of_group(user_id, shopping_list['group_id']):
                return "not a member"
            shopping_list['new_assigned_to_username'] = shopping_list['new_assigned_to']
            shopping_list['new_assigned_to'] = user_id
            

        if shopping_list.get('new_due_time'):
            shopping_list['new_due_time'] = datetime.strptime(shopping_list['new_due_time'], "%Y-%m-%d %H:%M:%S")

        if shopping_list.get('new_assigned_to') and shopping_list.get('new_due_time'):
            shopping_list['new_status'] = 'Active'
            
        updated_list = self.list_repo.update_shopping_list(shopping_list)
        return updated_list.as_dict()
    

    def get_shopping_lists(self, group_id, user_id):
        all_lists = self.list_repo.get_shopping_lists_by_group_id(group_id)
        is_admin = self.group_service.is_admin(user_id, group_id)
        if is_admin:
            return [list.as_dict() for list in all_lists]
            
        return [list.as_dict() for list in all_lists if list.assigned_to == user_id]
    

    def mark_list(self, group_id, list_id):
        shopping_list = self.list_repo.get_shopping_by_id(list_id)
        if not shopping_list:
            return "list not found"
        
        if shopping_list.status == 'Draft':
            return {"en": "Cannot change status of a draft shopping list.", "vn": "Không thể thay đổi trạng thái của danh sách mua sắm nháp."}

        if shopping_list.status == 'Active':
            self.change_status(group_id, list_id, 'Fully Completed')
            return {"en": "Shopping list marked as fully completed.", "vn": "Danh sách mua sắm được đánh dấu là hoàn thành."}
        if shopping_list.status == 'Fully Completed':
            self.change_status(group_id, list_id, 'Active')
            return {"en": "Shopping list marked as active.", "vn": "Danh sách mua sắm được đánh dấu là hoạt động."}


    def change_status(self, group_id, list_id, new_status):
        if new_status not in ['Active', 'Fully Completed', 'Partially Completed', 'Archived', 'Cancelled', 'Deleted']:
            return None
        
        _list = self.list_repo.update_shopping_list({
            'list_id': list_id,
            'group_id': group_id,
            'new_status': new_status
        })

        return _list.as_dict()