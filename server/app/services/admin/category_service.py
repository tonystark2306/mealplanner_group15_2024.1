import logging
from ...repository.category_repository import CategoryRepository


class CategoryService:
    def __init__(self):
        self.category_repository = CategoryRepository()
    
    
    def create_category_for_system(self, category_name):
        """ Create a category for the system """
        try:
            new_category = self.category_repository.create_system_category(category_name)
            return new_category
        except Exception as e:
            logging.error(f"Error creating system category: {str(e)}")
            raise
            
        