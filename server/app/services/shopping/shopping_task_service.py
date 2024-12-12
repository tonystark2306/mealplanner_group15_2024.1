from datetime import datetime

from ...repository.shopping_list_repository import ShoppingListRepository
from ...repository.shopping_task_repository import TaskRepository
from ...repository.food_repository import FoodRepository
from ...services.user.group_service import GroupService


class ShoppingTaskService:
    def __init__(self):
        self.group_service = GroupService()
        self.food_repo = FoodRepository()
        self.task_repo = TaskRepository()
        self.list_repo = ShoppingListRepository()


    def get_tasks_of_list(self, list_id, group_id, user_id):
        #check if shopping_list exists or not deleted
        shopping_list = self.list_repo.get_shopping_by_id(list_id)
        if not shopping_list:
            return "list not found"
        
        is_admin = user_id!= self.group_service.is_admin(user_id, shopping_list.group_id) 
        if not is_admin and user_id != shopping_list.assigned_to:
            return "you are not allowed to access this list"
        
        task_list = []
        for task in shopping_list.tasks:
            if task.status != 'Deleted':
                task_list.append(task.as_dict())
        return task_list

    def create_tasks(self, data):
        list_id = data['list_id']
        tasks = data['tasks']
        #check if shopping_list exists and is not cancelled
        shopping_list = self.list_repo.get_shopping_by_id(list_id)
        if not shopping_list:
            return "list not found"
        if shopping_list.status == 'Cancelled':
            return "list is cancelled"
        existed_tasks = shopping_list.tasks

        #check if food name exists
        #check if food already exists in the list
        #check if quantity is a number
        for task in tasks:
            food = self.food_repo.get_foods_by_name(task['food_name'])
            if not food:
                return "food not found"
            for existed_task in existed_tasks:
                if existed_task.food_id == food.id and existed_task.status == 'Active':
                    return "food already exists"
            task['food_id'] = food.id
            del task['food_name']
            try:
                task['quantity'] = float(task['quantity'])
            except:
                return "quantity must be a number"

            task['list_id'] = list_id
            self.task_repo.add_shopping_task(task)
        return "tasks created successfully"


    def update_task(self, new_task):

        #check status of task
        task = self.task_repo.get_task_by_id(new_task['list_id'],new_task['task_id'])
        if not task:
            return "task not found"
        if task.status == 'Cancelled' or task.status == 'Completed':
            return "task is cancelled or completed"
        
        #check food name, if other task has the same food name, merge them into one task
        food = self.food_repo.get_foods_by_name(new_task['new_food_name'])
        if not food:
            return "food not found"
        
        #merge case: reomonve existed task and update new task
        for existed_task in task.shopping_list.tasks:
            if existed_task.food_id == food.id and existed_task.status == 'Active':
                if existed_task.id != task.id:
                    new_task['new_food_id']=food.id
                    new_task['new_quantity'] = str(float(new_task['new_quantity']) + float(existed_task.quantity))
                    self.task_repo.update_task(new_task)
                    self.task_repo.update_task({
                        'list_id': existed_task.list_id,
                        'task_id': existed_task.id,
                        'new_status': 'Deleted'
                    })

        #normal case
        new_task['new_food_id'] = food.id
        new_task['new_quantity'] = float(new_task['new_quantity'])
        new_task['new_status'] = task.status
        self.task_repo.update_task(new_task)
        return "task updated successfully"
    

    def mark_task(self, list_id, task_id):
        task = self.task_repo.get_task_by_id(list_id, task_id)
        if not task:
            return "task not found"
        new_status = ''
        if task.status == 'Completed':
            new_status = 'Active'
        elif task.status == 'Active':
            new_status = 'Completed'

        result=self.change_task_status(task, new_status)
        return result


    def delete_task(self, list_id, task_id):
        task = self.task_repo.get_task_by_id(list_id, task_id)
        if not task:
            return "task not found"
        result=self.change_task_status(task, 'Deleted')
        return result


    def change_task_status(self, task, new_status):
        if new_status not in ['Active', 'Completed', 'Cancelled', 'Deleted']:
            return "invalid status"
        
        STATUS_TRANSITIONS = {
            'Active': ['Completed', 'Cancelled'],
            'Completed': [],
            'Cancelled': ['Active','Deleted'],
            'Deleted': []
        }
        if new_status not in STATUS_TRANSITIONS.get(task.status, []):
            return {
                "en": f"Cannot change status from {task.status} to {new_status}",
                "vn": f"Không thể thay đổi trạng thái từ {task.status} thành {new_status}"
                }

        new_task = {
            'list_id': task.list_id,
            'task_id': task.id,
            'new_status': new_status
        }
        self.task_repo.update_task(new_task)
        return "task status changed successfully"
        
