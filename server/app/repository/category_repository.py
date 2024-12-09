import logging
from typing import List

from .interface.category_interface import CategoryInterface
from ..models.category import Category as CategoryModel
from ..import db


class CategoryRepository(CategoryInterface):
    def __init__(self):
        pass
    
    
    def get_all_system_categories(self) -> List[CategoryModel]:
        return db.session.execute(
            db.select(CategoryModel).where(CategoryModel.type == "system")
        ).scalars().all()
    
    
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