from .. import db

from .interface.recipe_interface import RecipeInterface
from ..models.recipe import Recipe as RecipeModel
from ..models.recipe import RecipeImage as RecipeImageModel
from ..models.recipe import recipe_foods


class RecipeRepository(RecipeInterface):
    def __init__(self):
        self.image_repo = RecipeImageRepository()


    def get_recipe_by_id(self, recipe_id) -> RecipeModel:
        return db.session.query(RecipeModel).filter(RecipeModel.id == recipe_id, RecipeModel.is_deleted == False).first()
    

    def get_system_recipes(self) -> list:
        return db.session.query(RecipeModel).filter(RecipeModel.type == 'system', RecipeModel.is_deleted == False).all()
    
    
    def get_recipes_by_group_id(self, group_id) -> list:
        return db.session.query(RecipeModel).filter(RecipeModel.group_id == group_id, RecipeModel.type == 'custom', RecipeModel.is_deleted == False).all()
    

    def get_recipes_by_keywords(self, group_id, keyword) -> list:
        return db.session.query(RecipeModel).filter(RecipeModel.group_id == group_id, RecipeModel.dish_name.ilike(f'%{keyword}%'), RecipeModel.is_deleted == False).all() + db.session.query(RecipeModel).filter(RecipeModel.type == 'system', RecipeModel.dish_name.ilike(f'%{keyword}%'), RecipeModel.is_deleted == False).all()


    def get_system_recipe_by_name(self, recipe_name) -> RecipeModel:
        return db.session.query(RecipeModel).filter(RecipeModel.name == recipe_name, RecipeModel.type == 'system', RecipeModel.is_deleted == False).first()
    

    def get_group_recipe_by_name(self, recipe_name, group_id) -> RecipeModel:
        return db.session.query(RecipeModel).filter(RecipeModel.name == recipe_name, RecipeModel.group_id == group_id, RecipeModel.is_deleted == False).first()

    def add_recipe(self, recipe):
        try:
            new_recipe = RecipeModel(group_id=recipe['group_id'] or None,
                                    dish_name=recipe['name'],
                                    description=recipe.get('description') or None,
                                    content_html=recipe.get('content_html') or None,
                                    )
            
            db.session.add(new_recipe)
            db.session.commit()
            if recipe['foods']:
                self.add_recipe_foods(new_recipe.id, recipe['foods'])
            if recipe['images']:
                self.image_repo.add_image(new_recipe.id, recipe['images'])
            return new_recipe
        except Exception as e:
            db.session.rollback()
            print(e)
            raise e

    def add_recipe_foods(self, recipe_id, foods):
        # Lấy công thức dựa trên recipe_id và kiểm tra nếu chưa bị xóa
        recipe = db.session.query(RecipeModel).filter(RecipeModel.id == recipe_id, RecipeModel.is_deleted == False).first()
        if recipe:
            # Xử lý từng thực phẩm trong danh sách foods
            for f in foods:
                # Sử dụng bảng `recipe_foods` để thêm dữ liệu vào mối quan hệ
                recipe_food = {
                    'recipe_id': recipe.id,
                    'food_id': f['food_id'],
                    'quantity': f['quantity']
                }
                db.session.execute(recipe_foods.insert().values(recipe_food))
            db.session.commit()  # Cammit để lưu thay đổi vào cơ sở dữ liệu
        else:
            raise ValueError(f"No recipe found with id {recipe_id} or it is deleted.")


    def delete_recipe(self, recipe_id):
        recipe = db.session.query(RecipeModel).filter(RecipeModel.id == recipe_id, RecipeModel.is_deleted == False).first()
        if recipe:
            recipe.is_deleted = True
            #remove recipe_foods
            db.session.query(recipe_foods).filter(recipe_foods.c.recipe_id == recipe_id).delete()
            #set is_deleted = True for all images
            db.session.query(RecipeImageModel).filter(RecipeImageModel.recipe_id == recipe_id).update({'is_deleted': True})

            db.session.commit()
            return recipe
        else:
            raise ValueError(f"No recipe found with id {recipe_id} or it is deleted.")

class RecipeImageRepository:
    def __init__(self):
        pass


    def add_image(self, recipe_id, images):
        for i in images:
            new_image = RecipeImageModel(recipe_id=recipe_id,
                                         image_url=i['image_url'],
                                         order=i['order']
                                         )
            db.session.add(new_image)
        db.session.commit()
        return images
    

    def get_first_image(self, recipe_id):
        #lấy ra image có order thấp nhất
        return db.session.query(RecipeImageModel).filter(RecipeImageModel.recipe_id == recipe_id, RecipeImageModel.is_deleted==False).order_by(RecipeImageModel.order).first()
    

    def delete_image(self, image_id):
        image = db.session.query(RecipeImageModel).filter(RecipeImageModel.id == image_id, RecipeImageModel.is_deleted == False).first()
        if image:
            image.is_deleted = True
            db.session.commit()
            return image
        else:
            raise ValueError(f"No image found with id {image_id} or it is deleted.")