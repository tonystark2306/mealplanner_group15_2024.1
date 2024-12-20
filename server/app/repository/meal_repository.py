import logging
from typing import List
from .. import db
from sqlalchemy import func, desc

from .interface.meal_interface import MealPlanInterface
from ..models.meal_plan import MealPlan as MealPlanModel
from ..models.meal_plan import meal_plan_foods, meal_plan_recipes

class MealPlanRepository(MealPlanInterface):
    def get_meal_plan_by_id(self, meal_plan_id):
        meal = db.session.query(MealPlanModel).filter_by(id=meal_plan_id, is_deleted=False).first()
        return meal

    def get_meal_plan_by_group_id(self, group_id):
        meals = db.session.query(MealPlanModel).filter_by(group_id=group_id, is_deleted=False).order_by(desc(MealPlanModel.schedule_time)).all()
        return meals


    def get_meal_plan_by_date(self, group_id, date):
        #schedule_time = datetime.strptime(date, '%Y-%m-%d')
        #cắt ngày ra khỏi datetime của schedule_time trước khi so sánh
        meals = (
            db.session.query(MealPlanModel)
            .filter(
                MealPlanModel.group_id == group_id,
                func.date(MealPlanModel.schedule_time) == date,  # So sánh chỉ ngày, tháng, năm
                MealPlanModel.is_deleted == False
            )
            .order_by(desc(MealPlanModel.schedule_time))
            .all()
        )
        return meals


    def add_meal_plan(self, data):
        try:
            # Thêm MealPlan
            new_meal = MealPlanModel(
                group_id=data['group_id'],
                name=data['name'],
                schedule_time=data['schedule_time'],
                description=data.get('description') or None,
            )
            db.session.add(new_meal)
            db.session.flush()

            # Thêm các liên kết đến bảng meal_plan_recipes và meal_plan_foods
            if data.get('dishes'):
                self.add_meal_plan_recipes(new_meal.id, data['dishes'])
            if data.get('foods'):
                self.add_meal_plan_foods(new_meal.id, data['foods'])

            # Commit thay đổi vào database
            db.session.commit()
            return new_meal

        except Exception as e:
            db.session.rollback()  # Rollback toàn bộ nếu có lỗi
            logging.error(e)
            raise e


    def add_meal_plan_recipes(self, meal_plan_id, recipes):
        try:
            # Thực thi các câu lệnh thêm dữ liệu vào bảng liên kết meal_plan_recipes
            for r in recipes:
                db.session.execute(
                    meal_plan_recipes.insert().values(
                        plan_id=meal_plan_id,
                        recipe_id=r['recipe_id'],
                        servings=r['servings']
                    )
                )
        except Exception as e:
            logging.error(f"Error adding recipes to meal plan {meal_plan_id}: {e}")
            raise e


    def add_meal_plan_foods(self, meal_plan_id, foods):
        try:
            # Thực thi các câu lệnh thêm dữ liệu vào bảng liên kết meal_plan_foods
            for f in foods:
                db.session.execute(
                    meal_plan_foods.insert().values(
                        plan_id=meal_plan_id,
                        food_id=f['food_id'],
                        food_name=f['food_name'],
                        unit=f.get('unit'),
                        quantity=f['quantity']
                    )
                )
        except Exception as e:
            logging.error(f"Error adding foods to meal plan {meal_plan_id}: {e}")
            raise e


    def update_meal_plan(self, meal_plan_id, data):
        try:
            meal = db.session.query(MealPlanModel).filter_by(id=meal_plan_id, is_deleted=False).first()
            meal.name = data.get('new_name') or meal.name
            meal.schedule_time = data.get('new_schedule_time') or meal.schedule_time
            meal.description = data.get('new_description') or meal.description

            # Xóa các món ăn cũ
            db.session.query(meal_plan_recipes).filter_by(plan_id=meal_plan_id).delete()
            db.session.query(meal_plan_foods).filter_by(plan_id=meal_plan_id).delete()

            # Thêm món ăn mới
            if data['new_dishes']:
                self.add_meal_plan_recipes(meal_plan_id, data['new_dishes'])
            if data['new_foods']:
                self.add_meal_plan_foods(meal_plan_id, data['new_foods'])

            db.session.commit()
            return meal

        except Exception as e:
            db.session.rollback()
            logging.error(e)
            raise e
        

    def delete_meal_plan(self, meal_plan: MealPlanModel):
        try:
            meal = meal_plan
            meal.is_deleted = True
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            logging.error(e)
            raise e
        

    def change_meal_plan_status(self, meal_plan_id, new_status):
        try:
            meal = db.session.query(MealPlanModel).filter_by(id=meal_plan_id, is_deleted=False).first()
            meal.status = new_status
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            logging.error(e)
            raise e
