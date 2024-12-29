from datetime import datetime
import json
from collections import defaultdict

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
        #check if shopping_list exists and is not cancelled
        shopping_list = self.list_repo.get_shopping_by_id(list_id)
        if not shopping_list:
            return "list not found"
        if shopping_list.status == 'Cancelled':
            return "list is cancelled"
        if shopping_list.status == 'Fully Completed':
            return "list is completed"
        
        #kiểm tra danh sách task, nếu có task nào trùng tên thì merge chúng lại
        merged_tasks = defaultdict(float)
        # Duyệt qua danh sách tasks và gộp quantity
        for task in data["tasks"]:
            food_name = task["food_name"]
            quantity = float(task["quantity"])
            merged_tasks[food_name] += quantity
        # Chuyển dictionary thành danh sách
        merged_list = [{"food_name": food, "quantity": str(quantity)} for food, quantity in merged_tasks.items()]
        # Cập nhật lại tasks trong dữ liệu gốc
        data["tasks"] = merged_list
        tasks = data['tasks']

        #check if food name exists
        #check if food already exists in the list
        #check if quantity is a number
        existed_tasks = shopping_list.tasks
        for task in tasks:
            #kiểm tra xem cho 2 task cùng tên thì merge chúng lại
            food = self.food_repo.get_foods_by_name(task['food_name'])
            if not food:
                return "food not found"
            for existed_task in existed_tasks:
                if existed_task.food_id == food.id and existed_task.status == 'Active':
                    #merge case
                    existed_task.quantity = str(float(existed_task.quantity) + float(task['quantity']))
                    self.task_repo.update_task({
                        'list_id': existed_task.list_id,
                        'task_id': existed_task.id,
                        'new_quantity': existed_task.quantity
                    })

                    return "food already exists, merged successfully"
            task['food_id'] = food.id

            try:
                task['quantity'] = float(task['quantity'])
            except:
                return "quantity must be a number"

            task['list_id'] = list_id
            self.task_repo.add_shopping_task(task)
        return "tasks created successfully"


    def update_task(self, new_task):

        #check if shopping_list exists and is not cancelled
        shopping_list = self.list_repo.get_shopping_by_id(new_task['list_id'])
        if not shopping_list:
            return "list not found"
        if shopping_list.status == 'Cancelled':
            return "list is cancelled"
        if shopping_list.status == 'Fully Completed':
            return "list is completed"
        
        #check status of task
        task = self.task_repo.get_task_by_id(new_task['list_id'],new_task['task_id'])
        if not task:
            return "task not found"
        if task.status == 'Cancelled' or task.status == 'Fully Completed':
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
        #lấy danh sách task trong shopping_list, nếu tất cả task đều đã hoàn thành thì cập nhật shopping_list thành hoàn thành
        if new_status == 'Completed':
            shopping_list = self.list_repo.get_shopping_by_id(list_id)
            tasks = shopping_list.tasks
            if all(task.status == 'Completed' for task in tasks):
                self.list_repo.update_shopping_list({
                    'list_id': list_id,
                    'new_status': 'Fully Completed'
                })
                #TODO: thêm vào tủ lạnh sau
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
            'Active': ['Completed', 'Cancelled', 'Deleted'],
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
        
