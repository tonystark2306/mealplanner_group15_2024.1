from datetime import datetime

from ...repository.meal_repository import MealPlanRepository
from ...repository.recipe_repository import RecipeRepository
from ...repository.food_repository import FoodRepository
from ...repository.unit_repository import UnitRepository


class MealPlanService:
    def __init__(self):
        self.meal_repo = MealPlanRepository()
        self.recipe_repo = RecipeRepository()
        self.food_repo = FoodRepository()
        self.unit_repo = UnitRepository()


    def create_meal_plan(self, data):
        for recipe_data in data['dishes']:
            recipe = self.recipe_repo.get_recipe_by_id(recipe_data['recipe_id'])
            if not recipe:
                return "recipe not found"
            recipe_data.update({
                'servings': float(recipe_data.get('servings', 0.0))
            })

        for food_data in data['foods']:
            food = self.food_repo.get_food_by_id(food_data['food_id'])
            if not food:
                return "food not found"
            
            food_data.update({
                'food_name': food.name,
                'unit': food.unit.name,
                'quantity': float(food_data.get('quantity', 0.0))
            })


        meal_plan = self.meal_repo.add_meal_plan(data)
        return meal_plan.as_dict()


    def get_meal_day_plan(self, group_id, date):
        if not date:
            #lấy toàn bộ meal plan của group
            meal_plans = self.meal_repo.get_meal_plan_by_group_id(group_id)


        #kiểm tra định dạng ngày
        else:
            try:
                date = datetime.strptime(date, '%Y-%m-%d')
            except ValueError:
                return "date format is not correct"
            meal_plans = self.meal_repo.get_meal_plan_by_date(group_id, date)
            
        meal_plans_dict = []
        for meal_plan in meal_plans:
            meal_plan_dict = meal_plan.as_dict()
            meal_plans_dict.append(meal_plan_dict)

        return meal_plans_dict


    def get_detail_plan(self, meal_plan_id):
        meal_plan = self.meal_repo.get_meal_plan_by_id(meal_plan_id)
        if not meal_plan:
            return "meal plan not found"

        meal_plan_dict = meal_plan.as_dict()
        meal_plan_dict['dishes'] = []
        meal_plan_dict['foods'] = []

        for recipe in meal_plan.recipes:
            recipe_dict = recipe.as_dict()
            foods_dict = []
            for food in recipe.foods:
                food_dict = food.as_dict()
                foods_dict.append(food_dict)
            recipe_dict['foods'] = foods_dict
            meal_plan_dict['dishes'].append(recipe_dict)

        meal_plan_dict['foods'] = meal_plan.foods #do foods được trả về dưới dạng dict nên không cần xử lý thêm

        return meal_plan_dict
    

    def update_meal_plan(self, data):
        meal_plan = self.meal_repo.get_meal_plan_by_id(data['meal_id'])
        if not meal_plan:
            return "meal plan not found"

        for recipe_data in data['new_dishes']:
            recipe = self.recipe_repo.get_recipe_by_id(recipe_data['recipe_id'])
            if not recipe:
                return "recipe not found"
            recipe_data.update({
                'servings': float(recipe_data.get('servings', 0.0))
            })

        for food_data in data['new_foods']:
            food = self.food_repo.get_food_by_id(food_data['food_id'])
            if not food:
                return "food not found"
            food_data.update({
                'food_name': food.name,
                'unit': food.unit.name,
                'quantity': float(food_data.get('quantity', 0.0))
            })

        meal_plan = self.meal_repo.update_meal_plan(data['meal_id'], data)
        return meal_plan.as_dict()
    

    def delete_meal_plan(self, meal_plan_id):
        meal_plan = self.meal_repo.get_meal_plan_by_id(meal_plan_id)
        if not meal_plan:
            return "meal plan not found"

        self.meal_repo.delete_meal_plan(meal_plan)
        return "success"

    def mark_meal_plan(self, meal_plan_id):
        meal = self.meal_repo.get_meal_plan_by_id(meal_plan_id)
        if not meal:
            return "meal plan not found"
        
        current_time = datetime.now()
        
        if meal.status == 'Completed':
            if meal.schedule_time < current_time:
                meal.status = 'Cancelled'
            else:
                meal.status = 'Scheduled'
        else:
            meal.status = 'Completed'

        self.meal_repo.change_meal_plan_status(meal_plan_id, meal.status)
        return "success"
