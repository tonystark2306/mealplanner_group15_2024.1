from typing import List
from abc import ABC, abstractmethod
from ...models.category import Category as CategoryModel


class CategoryInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def get_category_by_name(self, category_name) -> CategoryModel:
        pass
    
    @abstractmethod
    def get_all_system_categories(self) -> List[CategoryModel]:
        pass
    
    @abstractmethod
    def create_system_category(self, category_name) -> CategoryModel:
        pass
    
    @abstractmethod
    def update_name_for_category(self, category, new_name):
        pass
    
    @abstractmethod
    def delete_category(self, category):
        pass