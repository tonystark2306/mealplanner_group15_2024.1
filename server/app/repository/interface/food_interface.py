from typing import List
from abc import ABC, abstractmethod
from ...models.food import Food as FoodModel


class FoodInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def get_all_foods_in_group(self, group_id) -> List[FoodModel]:
        pass
    
    @abstractmethod
    def get_food_by_id(self,id) -> FoodModel:
        pass
    
    @abstractmethod
    def get_foods_by_name(self, name) -> List[FoodModel]:
        pass
    
    @abstractmethod
    def get_food_in_group_by_name(self, group_id, food_name) -> FoodModel:
        pass
    
    @abstractmethod
    def get_food_categories(self) -> List[str]:
        pass
    
    @abstractmethod
    def create_food(self, user_id, group_id, image_url, data) -> FoodModel:
        pass

    @abstractmethod
    def update_food(self, food, data):
        pass
    
    @abstractmethod
    def delete_food(self, food):
        pass