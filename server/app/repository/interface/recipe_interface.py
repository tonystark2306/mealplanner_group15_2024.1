from abc import ABC, abstractmethod

from ...models.recipe import Recipe as RecipeModel


class RecipeInterface(ABC):
    
    def __init__(self):
        pass


    @abstractmethod
    def get_recipe_by_id(self, recipe_id) -> RecipeModel:
        pass


    @abstractmethod
    def get_recipe_by_name(self, recipe_name) -> RecipeModel:
        pass