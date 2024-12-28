from datetime import datetime
from werkzeug.utils import secure_filename

from ...repository.food_repository import FoodRepository
from ...repository.recipe_repository import RecipeRepository, RecipeImageRepository
from ...repository.unit_repository import UnitRepository
from ...utils.firebase_helper import FirebaseHelper



class RecipeService:
    def __init__(self):
        self.recipe_repo = RecipeRepository()
        self.image_repo = RecipeImageRepository()
        self.food_repo = FoodRepository()
        self.unit_repo = UnitRepository()
        self.firebase_helper = FirebaseHelper()


    def create_recipe(self, data):

        # Handle food data
        for food_data in data['foods']:
            food = self.food_repo.get_foods_by_name(food_data['food_name'])
            unit = self.unit_repo.get_unit_by_name(food_data['unit_name'])

            food_data.update({
                'food_id': food.id if food else None,
                'food_name': food.name if food else food_data['food_name'],
                'unit_id': unit.id if unit else None,
                'unit_name': unit.name if unit else food_data['unit_name'],
                'quantity': float(food_data.get('quantity', 0))
            })
        
        # Handle image data
        images = []
        for idx, image in enumerate(data['images']):
            if image.filename:
                filename = secure_filename(image.filename)
            image_url = self.firebase_helper.upload_image(image, f"recipe/{filename}")
            if image_url:
                images.append({"image_url": image_url, "order": idx})

        data['images'] = images
        recipe = self.recipe_repo.add_recipe(data)
        
        #trả về recipe đã tạo với cả danh sách thực phẩm và hình ảnh
        recipe_dict = recipe.as_dict()


        recipe_dict['foods'] = recipe.foods

        images_dict = []
        for image in recipe.images:
            REMOVED_FIELDS = ['created_at', 'updated_at', 'is_deleted']
            image_dict = image.as_dict()
            for field in REMOVED_FIELDS:
                del image_dict[field]
            images_dict.append(image_dict)
        recipe_dict['images'] = images_dict

        return recipe_dict
    

    def update_recipe(self, data):
        recipe= self.recipe_repo.get_recipe_by_id(data['recipe_id'])
        if not recipe:
            return "recipe not found"
        # Handle food data
        for food_data in data['foods']:
            food = self.food_repo.get_foods_by_name(food_data['food_name'])
            unit = self.unit_repo.get_unit_by_name(food_data['unit_name'])

            food_data.update({
                'food_id': food.id if food else None,
                'food_name': food.name if food else food_data['food_name'],
                'unit_id': unit.id if unit else None,
                'unit_name': unit.name if unit else food_data['unit_name'],
                'quantity': float(food_data.get('quantity', 0.0))
            })

        # Handle image data
        images = []
        for idx, image in enumerate(data['images']):
            if image.filename:
                filename = secure_filename(image.filename)
            image_url = self.firebase_helper.upload_image(image, f"recipe/{filename}")
            if image_url:
                images.append({"image_url": image_url, "order": idx})
        data['images'] = images
        recipe = self.recipe_repo.update_recipe(data)

        #trả về recipe đã tạo với cả danh sách thực phẩm và hình ảnh
        recipe_dict = recipe.as_dict()
        recipe_dict['foods'] = recipe.foods
        images_dict = []
        for image in recipe.images:
            REMOVED_FIELDS = ['created_at', 'updated_at', 'is_deleted']
            image_dict = image.as_dict()
            for field in REMOVED_FIELDS:
                del image_dict[field]
            images_dict.append(image_dict)
        recipe_dict['images'] = images_dict

        return recipe_dict

            
    def get_list_recipes(self, group_id):
        recipes = self.recipe_repo.get_recipes_by_group_id(group_id) + self.recipe_repo.get_system_recipes()

        recipes_dict = []
        REMOVED_FIELDS = ['content_html', 'created_at', 'updated_at', 'is_deleted']
        for recipe in recipes:
            recipe_dict = recipe.as_dict()
            for field in REMOVED_FIELDS:
                del recipe_dict[field]
            #lấy ra image có order = 0
            image = self.image_repo.get_first_image(recipe.id)
            if image:
                recipe_dict['image'] = image.image_url
            else:
                recipe_dict['image'] = None
            recipes_dict.append(recipe_dict)

        return recipes_dict


    def search_by_keyword(self, group_id, keyword):
        if not keyword:
            recipes = self.get_list_recipes(group_id)
        recipes = self.recipe_repo.search_by_keyword(group_id, keyword)
        if not recipes:
            return None
        
        recipes_dict = []
        REMOVED_FIELDS = ['content_html', 'created_at', 'updated_at', 'is_deleted', 'group_id', 'type', 'description', 'cooking_time']
        for recipe in recipes:
            recipe_dict = recipe.as_dict()
            for field in REMOVED_FIELDS:
                del recipe_dict[field]  
            recipes_dict.append(recipe_dict)
        return recipes_dict


    def get_recipe(self, recipe_id):
        recipe = self.recipe_repo.get_recipe_by_id(recipe_id)
        if not recipe:
            return None

        recipe_dict = recipe.as_dict()
        # REMOVED_FIELDS = ['created_at', 'updated_at', 'is_deleted']
        # for field in REMOVED_FIELDS:
        #     del recipe_dict[field]

        # Get foods
        recipe_dict['foods'] = recipe.foods

        # Get images
        images_dict = []
        for image in recipe.images:
            images_dict.append(image.as_dict())
        recipe_dict['images'] = images_dict

        return recipe_dict
    

    def delete_recipe(self, recipe_id):
        recipe = self.recipe_repo.get_recipe_by_id(recipe_id)
        if not recipe:
            return "recipe not found"

        self.recipe_repo.delete_recipe(recipe_id)
        return recipe_id