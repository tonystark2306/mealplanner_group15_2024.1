from ...models.food import Food as FoodModel
from typing import List



class FoodInterface:
    def get_foods_by_name(self, name) -> List[FoodModel]:
        pass


    def get_food_categories(self) -> List[str]:
        pass