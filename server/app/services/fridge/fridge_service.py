import logging
from datetime import datetime
from typing import Optional, Tuple

from ...repository.fridgeItem_repository import FridgeItemRepository
from ...repository.food_repository import FoodRepository
from ...repository.unit_repository import UnitRepository
from ...repository.category_repository import CategoryRepository

class FridgeService:
    def __init__(self) -> None:
        self.fridge_repo = FridgeItemRepository()
        self.food_repo = FoodRepository()
        self.unit_repo = UnitRepository()


    def get_group_fridge(self, group_id: str):
        fridge_items = self.fridge_repo.get_fridgeItem_by_group_id(group_id)
        fridge_dict = []
        for item in fridge_items:
            item_dict = item.as_dict()
            food = self.food_repo.get_food_by_id(item.food_id)
            food_dict = food.as_dict()
            unit_dict = self.unit_repo.get_unit_by_id(food.unit_id).as_dict()
            item_dict['Food'] = food_dict
            categories = self.food_repo.get_food_categories(item.food_id)
            categories_dict = []
            for category in categories:
                categories_dict.append(category.name)
            item_dict['Food']['Unit'] = unit_dict
            item_dict['Food']['Categories'] = categories_dict

            fridge_dict.append(item_dict)

        return fridge_dict
        

    def get_specific_item(self, item_id: str):

        #tìm item có group_id:
        item = self.fridge_repo.get_item_by_id(item_id)
        if not item:
            return "item not found"

        item_dict = item.as_dict()

        food = self.food_repo.get_food_by_id(item.food_id)
        if not food:
            return "food not found"
        food_dict = food.as_dict()

        unit = self.unit_repo.get_unit_by_id(food.unit_id)
        unit_dict = unit.as_dict()
        categories = self.food_repo.get_food_categories(item.food_id)
        categories_dict = []
        for category in categories:
            categories_dict.append(category.name)
        food_dict['Unit'] = unit_dict
        food_dict['Categories'] = categories_dict

        item_dict['Food'] = food_dict

        return item_dict


    def add_item_to_fridge(self, data: dict) -> Tuple[str, Optional[str]]:
        food = self.food_repo.get_foods_by_name(data['foodName'])
        if not food:
            return "food item not found"

        convert_date = datetime.strptime(data['expiration_date'], "%Y-%m-%d %H:%M:%S")

        frigde_item = self.fridge_repo.add_item(data['owner_id'], data['added_by'], food.id, data['quantity'], convert_date)
        if not frigde_item:
            return "error adding item to fridge"
        
        food_dict = food.as_dict()
        unit = self.unit_repo.get_unit_by_id(food.unit_id)
        unit_dict = unit.as_dict()
        categories = self.food_repo.get_food_categories(food.id)
        categories_dict = []
        for category in categories:
            categories_dict.append(category.name)
        food_dict['Unit'] = unit_dict
        food_dict['Categories'] = categories_dict

        frigde_item_dict = frigde_item.as_dict()
        frigde_item_dict['Food'] = food_dict

        return frigde_item_dict
    

    def update_fridge_item(self, data: dict) -> Tuple[str, Optional[str]]:
        item = self.fridge_repo.get_item_by_id(data['itemId'])
        if not item:
            return "item not found"
        new_food= self.food_repo.get_foods_by_name(data['newFoodName'])
        if not new_food:
            return "food not found"
        convert_date = datetime.strptime(data['newExpiration_date'], "%Y-%m-%d %H:%M:%S")
        updated_item = self.fridge_repo.update_item(data['itemId'], data['owner_id'], data['added_by'], new_food.id, data['newQuantity'], convert_date)
        return updated_item.as_dict()
    


    #hàm nhập thực phẩm từ shopping list vào tủ lạnh
    def add_item_from_shopping_list(self, data: dict):
        #kiểm tra xem thực phẩm đã tồn tại trong tủ lạnh chưa
        fridge_item = self.fridge_repo.get_item_by_food_id(data['food_id'])
        if fridge_item:
            #nếu thực phẩm đã tồn tại thì cập nhật số lượng
            new_quantity = float(fridge_item.quantity) + float(data['quantity'])
            updated_item = self.fridge_repo.update_item(fridge_item.id, fridge_item.owner_id, fridge_item.added_by, fridge_item.food_id, new_quantity, fridge_item.expiration_date)
            return updated_item.as_dict()
        else:
            #nếu thực phẩm chưa tồn tại thì thêm vào tủ lạnh
            convert_date = datetime.strptime(data['expiration_date'], "%Y-%m-%d %H:%M:%S")
            new_item = self.fridge_repo.add_item(data['owner_id'], data['added_by'], data['food_id'], data['quantity'], convert_date)
            return new_item.as_dict()
            

    def delete_fridge_item(self, item_id: str):
        item = self.fridge_repo.get_item_by_id(item_id)
        if not item:
            return "item not found"
        self.fridge_repo.delete_item(item_id)
        return "item deleted"