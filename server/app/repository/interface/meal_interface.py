from abc import ABC, abstractmethod
from typing import List

from ...models.meal_plan import MealPlan as MealPlanModel



class MealPlanInterface(ABC):
    def __init__(self):
        pass
    
    @abstractmethod
    def get_meal_plan_by_id(self, meal_plan_id) -> MealPlanModel:
        pass


    @abstractmethod
    def get_meal_plan_by_group_id(self, group_id) -> List[MealPlanModel]:
        pass


    @abstractmethod
    def get_meal_plan_by_date(self, group_id, date) -> List[MealPlanModel]:
        pass