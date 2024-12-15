from abc import ABC, abstractmethod

from ...models.shopping import ShoppingTask as ShoppingTaskModel


class TaskInterface(ABC):
    def __init__(self):
        pass

    @abstractmethod
    def get_task_by_id(self, task_id):
        pass
    
    @abstractmethod
    def get_task_by_list_id(self, list_id):
        pass