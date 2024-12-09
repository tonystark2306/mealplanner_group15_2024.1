from .. import db


from .interface.task_interface import TaskInterface
from ..models.shopping import ShoppingTask as ShoppingTaskModel


class TaskRepository(TaskInterface):
    def __init__(self):
        pass

    def get_task_by_id(self, task_id):
        return db.session.query(ShoppingTaskModel).filter_by(id=task_id).first()


    def get_task_by_list_id(self, list_id):
        return ShoppingTaskModel.query.filter_by(list_id=list_id).all()