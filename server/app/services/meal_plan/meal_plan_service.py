from datetime import datetime

from ...repository.meal_repository import MealPlanRepository
from ...repository.recipe_repository import RecipeRepository
from ...repository.food_repository import FoodRepository
from ...repository.unit_repository import UnitRepository

from ...services.recipe.recipe_service import RecipeService



class MealPlanService:
    def __init__(self):
        self.meal_repo = MealPlanRepository()
        self.recipe_repo = RecipeRepository()
        self.food_repo = FoodRepository()
        self.unit_repo = UnitRepository()

        self.recipe_service = RecipeService()


    def create_meal_plan(self, data):
        for recipe_data in data['dishes']:
            recipe = self.recipe_repo.get_recipe_by_id(recipe_data['recipe_id'])
            if not recipe:
                recipe = self.recipe_repo.get_system_recipe_by_name(recipe_data['recipe_name'])
            if not recipe:
                recipe = self.recipe_repo.get_group_recipe_by_name(recipe_data['recipe_name'], data['group_id'])
            if not recipe:
                return "recipe not found"
            recipe_data.update({
                'recipe_id': recipe.id,
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
            
        meal_plans_dicts = []
        for meal_plan in meal_plans:
            meal_plan_dict = meal_plan.as_dict()
            meal_plan_dict['dishes'] = []
            meal_plan_dict['foods'] = []

            #get recipe serving
            meal_plan_dict['dishes'] = self.meal_repo.get_recipes_serving(meal_plan.id)
            #get recipe detail
            for recipe in meal_plan_dict['dishes']:
                recipe_dict = self.recipe_service.get_recipe(recipe['recipe_id'])
                recipe.update(recipe_dict)

            #get food detail
            meal_plan_dict['foods'] = self.meal_repo.get_foods(meal_plan.id)

            meal_plans_dicts.append(meal_plan_dict)

        return meal_plans_dicts



    def get_detail_plan(self, meal_plan_id):
        meal_plan = self.meal_repo.get_meal_plan_by_id(meal_plan_id)
        if not meal_plan:
            return "meal plan not found"

        meal_plan_dict = meal_plan.as_dict()
        meal_plan_dict['dishes'] = []
        meal_plan_dict['foods'] = []

        #get recipe serving
        meal_plan_dict['dishes'] = self.meal_repo.get_recipes_serving(meal_plan_id)
        #get recipe detail
        for recipe in meal_plan_dict['dishes']:
            recipe_dict = self.recipe_service.get_recipe(recipe['recipe_id'])
            recipe.update(recipe_dict)

        #get food detail
        meal_plan_dict['foods'] = self.meal_repo.get_foods(meal_plan_id)

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
