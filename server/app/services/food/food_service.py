import logging

from werkzeug.utils import secure_filename

from ...repository.food_repository import FoodRepository
from ...utils.firebase_helper import FirebaseHelper


class FoodService:
    def __init__(self):
        self.food_repository = FoodRepository()
        self.firebase_helper = FirebaseHelper()
        
        
    def get_all_foods_in_group(self, group_id):
        foods = self.food_repository.get_all_foods_in_group(group_id)
        return [food.as_dict() for food in foods]
        
        
    def get_food_in_group_by_name(self, group_id, food_name):
        return self.food_repository.get_food_in_group_by_name(group_id, food_name)

    
    def save_new_food(self, user_id, group_id, image_file, data):
        try:
            filename = secure_filename(image_file.filename)
            image_url = self.firebase_helper.upload_image(image_file, f"food_images/{filename}")
            new_food = self.food_repository.create_food(user_id, group_id, image_url, data)
            return new_food
        
        except Exception as e:
            logging.error(f"Error while saving new food: {str(e)}")
            raise
        
        
    def update_food_info(self, food, data, image_file):
        try:
            if data:
                is_updated = self.food_repository.update_food(food, data)
                if not is_updated:
                    return None
                
            if image_file:
                filename = secure_filename(image_file.filename)
                image_url = self.firebase_helper.upload_image(image_file, f"food_images/{filename}")
                is_updated = self.food_repository.update_food(food, {"image_url": image_url})
                if not is_updated:
                    return None
               
            return food
        
        except Exception as e:
            logging.error(f"Error updating food info: {str(e)}")
            raise
        
        
    def delete_food_from_db(self, food):
        try:
            self.food_repository.delete_food(food)
            
        except Exception as e:
            logging.error(f"Error while deleting food: {str(e)}")
            raise
        
        
    def search_foods_in_group(self, group_id, query):
        try:
            foods = self.food_repository.search_foods_in_group(group_id, query)
            return [food.as_dict() for food in foods]
        
        except Exception as e:
            logging.error(f"Error while searching foods: {str(e)}")
            raise