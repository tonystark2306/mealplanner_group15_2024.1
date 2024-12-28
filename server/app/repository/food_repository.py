import logging
from typing import List

from .. import db
from ..models.food import Food as FoodModel
from .interface.food_interface import FoodInterface
from .category_repository import CategoryRepository
from .unit_repository import UnitRepository
from .user_repository import UserRepository


class FoodRepository(FoodInterface):
    def __init__(self):
        self.category_repository = CategoryRepository()
        self.unit_repository = UnitRepository()
        self.user_repository = UserRepository()
        
        
    def get_all_foods_in_group(self, group_id) -> List[FoodModel]:
        return db.session.query(FoodModel).filter_by(group_id=group_id).all()


    def get_food_by_id(self,id) -> FoodModel:
        return db.session.query(FoodModel).filter_by(id=id).first()


    def get_foods_by_name(self, name) -> List[FoodModel]:
        #trả về 1 thực phẩm duy nhất
        return db.session.query(FoodModel).filter_by(name=name).first()
    
    
    def get_food_in_group_by_name(self, group_id, food_name) -> FoodModel:
        return db.session.query(FoodModel).filter_by(group_id=group_id, name=food_name).first()
    

    def get_food_categories(self, id) -> List[str]:
        food = db.session.query(FoodModel).filter_by(id=id).first()
        return food.categories

    
    def create_food(self, user_id, group_id, image_url, data) -> FoodModel:
        try:
            user = self.user_repository.get_user_by_id(user_id)
            category = self.category_repository.get_category_by_name(data["categoryName"])
            unit = self.unit_repository.get_unit_by_name(data["unitName"])
            if not user or not category or not unit:
                return None
            
            new_food = FoodModel(user_id, data["name"], data["type"], group_id, category, unit.id, image_url, data["note"])
            new_food.creator_username = user.username
            new_food.category_name = category.name
            new_food.unit_name = unit.name
            db.session.add(new_food)
            db.session.commit()
            return new_food
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error creating food: {str(e)}")
            raise
        
        
    def update_food(self, food, data) -> bool:
        try:
            if "type" in data:
                food.type = data["type"]
            if "note" in data:
                food.note = data["note"]
            if "categoryName" in data:
                new_category = self.category_repository.get_category_by_name(data["categoryName"])
                if not new_category:
                    return False
                food.categories = [new_category]
                food.category_name = new_category.name
            if "unitName" in data:
                new_unit = self.unit_repository.get_unit_by_name(data["unitName"])
                if not new_unit:
                    return False
                food.unit_id = new_unit.id
                food.unit_name = new_unit.name
                    
            db.session.commit()
            return True
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error updating food: {str(e)}")
            raise
        
        
    def delete_food(self, food):
        try:
            db.session.delete(food)
            db.session.commit()
            
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error deleting food: {str(e)}")
            raise