import logging

from werkzeug.utils import secure_filename

from ...repository.food_repository import FoodRepository
from ...utils.firebase_helper import FirebaseHelper


class FoodService:
    def __init__(self):
        self.food_repository = FoodRepository()
        self.firebase_helper = FirebaseHelper()
    
    
    def save_new_food(self, user_id, group_id, image_file, data):
        try:
            filename = secure_filename(image_file.filename)
            image_url = self.firebase_helper.upload_image(image_file, f"food_images/{filename}")
            new_food = self.food_repository.create_food(user_id, group_id, image_url, data)
            return new_food
        
        except Exception as e:
            logging.error(f"Error while saving new food: {str(e)}")
            raise
