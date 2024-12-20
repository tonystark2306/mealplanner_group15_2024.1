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
        data['recipes'] = data['dishes']

        for food_data in data['foods']:
            food = self.food_repo.get_food_by_id(food_data['food_id'])
            if not food:
                return "food not found"
            
            food_data.update({
                'food_name': food.name,
                'unit': food.unit,
                'quantity': float(food_data.get('quantity', 0.0))
            })


        meal_plan = self.meal_repo.add_meal_plan(data)
        return meal_plan.as_dict()


    def get_meal_day_plan(self, group_id, date):
        if not date:
            #lấy toàn bộ meal plan của group
            meal_plans = self.meal_repo.get_meal_plan_by_group_id(group_id)
        
        else:
            #lấy meal plan của group theo ngày
            date = datetime.strptime(date, '%Y-%m-%d')
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
        meal_plan_dict['recipes'] = []
        meal_plan_dict['foods'] = []

        for recipe in meal_plan.recipes:
            recipe_dict = recipe.as_dict()
            foods_dict = []
            for food in recipe.foods:
                food_dict = food.as_dict()
                foods_dict.append(food_dict)
            recipe_dict['foods'] = foods_dict
            meal_plan_dict['recipes'].append(recipe_dict)

        for food in meal_plan.foods:
            food_dict = food.as_dict()
            meal_plan_dict['foods'].append(food_dict)

        return meal_plan_dict