import logging
from typing import List
from .. import db
from sqlalchemy import func, desc

from .interface.meal_interface import MealPlanInterface
from ..models.meal_plan import MealPlan as MealPlanModel
from ..models.meal_plan import meal_plan_foods, meal_plan_recipes

class MealPlanRepository(MealPlanInterface):
    def get_meal_plan_by_id(self, meal_plan_id):
        meal = db.session.query(MealPlanModel).filter_by(id=meal_plan_id).first()

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
            new_meal = MealPlanModel(group_id=data['group_id'],
                                     name = data['name'],
                                    schedule_time=data['schedule_time'],
                                    description=data.get('description') or None,
                                    )
            db.session.add(new_meal)
            if data['recipes']:
                self.add_meal_plan_recipes(new_meal.id, data['dishes'])
            if data['foods']:
                self.add_meal_plan_foods(new_meal.id, data['foods'])

            db.session.commit()
            return new_meal
        except Exception as e:
            db.session.rollback()
            logging.error(e)
            raise e
        
    def add_meal_plan_recipes(self, meal_plan_id, recipes):
        meal = db.session.query(MealPlanModel).filter(MealPlanModel.id == meal_plan_id, MealPlanModel.is_deleted == False).first()
        if meal:
            for r in recipes:
                meal_recipe = {
                    'plan_id': meal.id,
                    'recipe_id': r['recipe_id'],
                    'servings': r['serving']
                }
                meal_plan_recipes.insert().values(meal_recipe)

    def add_meal_plan_foods(self, meal_plan_id, foods):
        meal = db.session.query(MealPlanModel).filter(MealPlanModel.id == meal_plan_id, MealPlanModel.is_deleted == False).first()
        if meal:
            for f in foods:
                meal_food = {
                    'plan_id': meal.id,
                    'food_id': f['food_id'],
                    'food_name': f['food_name'],
                    'unit': f['unit'],
                    'quantity': f['quantity']
                }
                meal_plan_foods.insert().values(meal_food)