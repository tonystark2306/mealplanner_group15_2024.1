from ..models.food import Food as FoodModel
from typing import List
from .. import db
from abc import ABC, abstractmethod
from .interface.food_interface import FoodInterface

class FoodRepository(FoodInterface):
    def __init__(self):
        pass


    def get_food_by_id(self,id) -> FoodModel:
        return db.session.query(FoodModel).filter_by(id=id).first()


    def get_foods_by_name(self, name) -> List[FoodModel]:
        #trả về 1 thực phẩm duy nhất
        return db.session.query(FoodModel).filter_by(name=name).first()
    

    def get_food_categories(self, id) -> List[str]:
        food = db.session.query(FoodModel).filter_by(id=id).first()
        return food.categories
