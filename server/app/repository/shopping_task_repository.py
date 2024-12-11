from .. import db


from .interface.task_interface import TaskInterface
from ..models.shopping import ShoppingTask as ShoppingTaskModel


class TaskRepository(TaskInterface):
    def __init__(self):
        pass

    def get_task_by_id(self,list_id, task_id):
        return db.session.query(ShoppingTaskModel).filter(
            ShoppingTaskModel.list_id == list_id,
            ShoppingTaskModel.id == task_id,
            ShoppingTaskModel.status != 'Deleted'
        ).first()


    def get_task_by_list_id(self, list_id):
        return db.session.query(ShoppingTaskModel).filter(ShoppingTaskModel.list_id == list_id, 
                                                          ShoppingTaskModel.status != 'Deleted').all()
    

    def add_shopping_task(self, task):
        new_task = ShoppingTaskModel(list_id=task['list_id'],
                                     food_id=task['food_id'],
                                     quantity=task['quantity']
                                     )
        db.session.add(new_task)
        db.session.commit()
        return new_task
    

    def update_task(self, task):
        _task = db.session.query(ShoppingTaskModel).filter(ShoppingTaskModel.list_id == task['list_id'],
                                                           ShoppingTaskModel.id == task['task_id'], 
                                                           ShoppingTaskModel.status != 'Deleted').first()
        if task is not None and _task is not None:
            _task.food_id = task.get('new_food_id') or _task.food_id
            _task.quantity = task.get('new_quantity') or _task.quantity
            _task.status = task.get('new_status') or _task.status

        db.session.commit()
        return _task
    

