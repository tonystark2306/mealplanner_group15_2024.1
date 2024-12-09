from abc import ABC, abstractmethod
from typing import List
from ...models.fridge_item import FridgeItem as FridgeItemModel



class FridgeInterface(ABC):
    @abstractmethod
    def get_fridgeItem_by_group_id(self, group_id: str) -> List[FridgeItemModel]:
        pass


    def get_item_by_food_id(self, food_id: str) -> FridgeItemModel:
        pass


    # @abstractmethod
    # def get_fridgeItem_by_user_id(self, user_id: str) -> List[FridgeItemModel]:
    #     pass


    @abstractmethod
    def add_item(self, owner_id: str, food_id: str, added_by: str, quantity: float, expiration_date: str) -> FridgeItemModel:
        pass


    # @abstractmethod
    # def remove_item(self, owner_id: str, food_id: str) -> None:
    #     pass


    # @abstractmethod
    # def update_item(self, owner_id: str, food_id: str, quantity: float, expiration_date: str) -> FridgeItemModel:
    #     pass