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
            
    
    def list_system_categories(self):
        """ List all system categories """
        return self.category_repository.get_all_system_categories()
    
    
    def get_category_by_name(self, name):
        """ Get a system category by name """
        return self.category_repository.get_category_by_name(name)
    
    
    def update_category_name(self, category, new_name):
        """ Update the name of a category """
        try:
            self.category_repository.update_name_for_category(category, new_name)
        except Exception as e:
            logging.error(f"Error updating category name: {str(e)}")
            raise
    
    
    def delete_category(self, category):
        """ Delete a system category"""
        try:
            self.category_repository.delete_category(category)
        except Exception as e:
            logging.error(f"Error deleting system category: {str(e)}")
            raise