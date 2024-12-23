import logging
from typing import List

from .. import db
from ..models.food import Food as FoodModel
from .interface.food_interface import FoodInterface
from .category_repository import CategoryRepository
from .unit_repository import UnitRepository


class FoodRepository(FoodInterface):
    def __init__(self):
        self.category_repository = CategoryRepository()
        self.unit_repository = UnitRepository()


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
            categories = []
            for name in data["foodCategoryNames"]:
                category = self.category_repository.get_category_by_name(name)
                if not category:
                    return None
                categories.append(category)
                
            unit = self.unit_repository.get_unit_by_name(data["unitName"])
            if not unit:
                return None
            
            new_food = FoodModel(user_id, data["name"], data["type"], group_id, categories, unit.id, image_url, data["note"])
            db.session.add(new_food)
            db.session.commit()
            return new_food
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error creating food: {str(e)}")
            raise
        
        
    def update_food(self, food, data):
        try:
            for field, value in data.items():
                setattr(food, field, value)
            db.session.commit()
        
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