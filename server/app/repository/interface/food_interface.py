from ...models.food import Food as FoodModel
from typing import List



class FoodInterface:
    def get_foods_by_name(self, name) -> List[FoodModel]:
        pass
