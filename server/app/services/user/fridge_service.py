import logging

from ...repository.fridgeItem_repository import FridgeItemRepository
from ...repository.food_repository import FoodRepository
from ...repository.user_repository import UserRepository
from datetime import datetime

class FridgeService:
    def __init__(self) -> None:
        self.fridge_repo = FridgeItemRepository()
        self.food_repo = FoodRepository()
        self.user_repo = UserRepository()

    def get_frideItem_of_group(self, group_id: str):
        return self.fridge_repo.get_fridgeItem_by_group_id(group_id)
    
    def add_item_to_fridge(self, owner_id: str, user_id: str, food_name: str, quantity: float, str_datetime: str):
        food = self.food_repo.get_foods_by_name(food_name)
        if not food:
            return "Food item not found"
        food_id = food.id

        convert_date = datetime.strptime(str_datetime, "%Y-%m-%d %H:%M:%S")
        return self.fridge_repo.add_item(owner_id, food_id, user_id, quantity, convert_date)