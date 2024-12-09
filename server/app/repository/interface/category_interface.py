from abc import ABC, abstractmethod
from ...models.category import Category as CategoryModel


class CategoryInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def create_system_category(self, category_name) -> CategoryModel:
        pass