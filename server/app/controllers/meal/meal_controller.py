from flask import request, jsonify

from . import meal_api
from ...services.meal_plan.meal_plan_service import MealPlanService
from ...utils.decorator import JWT_required, group_member_required, group_admin_required
from ...utils.middleware import validate_fields



@meal_api.route("/<group_id>", methods=["POST"])
@JWT_required
@group_admin_required
def create_meal_plan(user_id, group_id):
    meal_plan_service = MealPlanService()
    data = request.json

    data["group_id"] = group_id
    result = meal_plan_service.create_meal_plan(data)

    return jsonify({
        "resultMessage": {
            "en": "Meal plan created successfully",
            "vn": "Tạo kế hoạch ăn thành công"
        },
        "resultCode": "00202",
        "meal_plan": result
    }), 201


@meal_api.route("/<group_id>", methods=["GET"])
@JWT_required
@group_member_required
def get_meal_day_plan(user_id, group_id):
    meal_plan_service = MealPlanService()

    date = request.args.get("date")
    result = meal_plan_service.get_meal_day_plan(group_id, date)

    return jsonify({
        "resultMessage": {
            "en": "Successfully retrieved meal plan",
            "vn": "Lấy kế hoạch ăn thành công"
        },
        "resultCode": "00228",
        "meal_plan": result
    }), 200