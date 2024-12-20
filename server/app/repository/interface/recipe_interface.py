from abc import ABC, abstractmethod

from ...models.recipe import Recipe as RecipeModel


class RecipeInterface(ABC):
    
    def __init__(self):
        pass


    @abstractmethod
    def get_recipe_by_id(self, recipe_id) -> RecipeModel:
        pass


    @abstractmethod
    def get_system_recipes(self) -> list[RecipeModel]:
        pass

    
    @abstractmethod
    def get_recipes_by_group_id(self, group_id) -> list[RecipeModel]:
        pass


    @abstractmethod
    def get_system_recipe_by_name(self, recipe_name) -> RecipeModel:
        pass


    @abstractmethod
    def get_group_recipe_by_name(self, recipe_name, group_id) -> RecipeModel:
        pass


    @abstractmethod
    def add_recipe(self, recipe) -> RecipeModel:
        pass


    @abstractmethod
    def add_recipe_foods(self, recipe_id, foods):
        pass


    @abstractmethod
    def delete_recipe(self, recipe_id):
        pass


    @abstractmethod
    def get_recipes_by_keywords(self, keywords) -> list[RecipeModel]:
        pass



class RecipeImageInterface(ABC):
    
    def __init__(self):
        pass


    @abstractmethod
    def add_image(self, recipe_id, images):
        pass


    @abstractmethod
    def get_first_image(self, recipe_id):
        pass


    @abstractmethod
    def delete_image(self, image_id):
        pass