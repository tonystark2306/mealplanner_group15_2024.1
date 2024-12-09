import logging

from .interface.category_interface import CategoryInterface
from ..models.category import Category as CategoryModel
from ..import db


class CategoryRepository(CategoryInterface):
    def __init__(self):
        pass
    
    
    def create_system_category(self, category_name) -> CategoryModel:
        try:
            new_category = CategoryModel(
                name=category_name,
                type="system"
            )
            db.session.add(new_category)
            db.session.commit()
            return new_category
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error creating system category: {str(e)}")
            raise