import logging
from typing import List

from sqlalchemy import and_

from .interface.category_interface import CategoryInterface
from ..models.category import Category as CategoryModel
from ..import db


class CategoryRepository(CategoryInterface):
    def __init__(self):
        pass
    
    
    def get_category_by_name(self, category_name) -> CategoryModel:
        return db.session.execute(
            db.select(CategoryModel).where(
                and_(
                    CategoryModel.type == "system",
                    CategoryModel.name == category_name
                )
            )
        ).scalar()
    
    
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
        
        
    def update_name_for_category(self, category, new_name):
        try:
            category.name = new_name
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error updating category name: {str(e)}")
            raise
        
        
    def delete_category(self, category):
        try:
            db.session.delete(category)
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error deleting system category: {str(e)}")
            raise