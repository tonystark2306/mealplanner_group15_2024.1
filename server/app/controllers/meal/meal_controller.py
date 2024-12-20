from flask import request, jsonify

from . import meal_api
from ...services.meal_plan.meal_plan_service import MealPlanService
from ...utils.decorator import JWT_required, group_member_required, group_admin_required
from ...utils.middleware import validate_fields, check_meal_plan_ownership



@meal_api.route("/<group_id>", methods=["POST"])
@JWT_required
@group_admin_required
def create_meal_plan(user_id, group_id):
    meal_plan_service = MealPlanService()
    data = request.json

    data["group_id"] = group_id
    result = meal_plan_service.create_meal_plan(data)

    if result == "recipe not found":
        return jsonify({
            "resultMessage": {
                "en": "Recipe not found",
                "vn": "Không tìm thấy công thức nấu ăn trong kế hoạch của bạn"
            },
            "resultCode": "00226"
        }), 404
    
    if result == "food not found":
        return jsonify({
            "resultMessage": {
                "en": "Food not found",
                "vn": "Không tìm thấy một hoặc nhiều thực phẩm trong kế hoạch của bạn"
            },
            "resultCode": "00226"
        }),

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

    if result == "date format is not correct":
        return jsonify({
            "resultMessage": {
                "en": "Date format is not correct",
                "vn": "Định dạng ngày không đúng"
            },
            "resultCode": "00227"
        }), 400
    
    return jsonify({
        "resultMessage": {
            "en": "Successfully retrieved meal plan",
            "vn": "Lấy kế hoạch ăn thành công"
        },
        "resultCode": "00228",
        "meal_plan": result
    }), 200


@meal_api.route("/<group_id>", methods=["PUT"])
@JWT_required
@group_admin_required
@validate_fields(["meal_id"])
@check_meal_plan_ownership
def update_meal_plan(user_id, group_id):
    meal_plan_service = MealPlanService()
    data = request.json

    data["group_id"] = group_id
    result = meal_plan_service.update_meal_plan(data)

    if result == "meal plan not found":
        return jsonify({
            "resultMessage": {
                "en": "Meal plan not found",
                "vn": "Không tìm thấy kế hoạch bữa ăn với ID này"
            },
            "resultCode": "00229"
        }), 404
    
    if result == "recipe not found":
        return jsonify({
            "resultMessage": {
                "en": "Recipe not found",
                "vn": "Không tìm thấy công thức nấu ăn trong kế hoạch của bạn"
            },
            "resultCode": "00226"
        }),

    if result == "food not found":
        return jsonify({
            "resultMessage": {
                "en": "Food not found",
                "vn": "Không tìm thấy một hoặc nhiều thực phẩm trong kế hoạch của bạn"
            },
            "resultCode": "00226"
        }),

    return jsonify({
        "resultMessage": {
            "en": "Meal plan updated successfully",
            "vn": "Cập nhật kế hoạch ăn thành công"
        },
        "resultCode": "00229",
        "meal_plan": result
    }), 200


@meal_api.route("/<group_id>/<meal_id>", methods=["GET"])
@JWT_required
@group_member_required
@check_meal_plan_ownership
def get_detail_plan(user_id, group_id, meal_id):
    meal_plan_service = MealPlanService()
    result = meal_plan_service.get_detail_plan(meal_id)

    if result == "meal plan not found":
        return jsonify({
            "resultMessage": {
                "en": "Meal plan not found",
                "vn": "Không tìm thấy kế hoạch bữa ăn với ID này"
            },
            "resultCode": "00229"
        }), 404

    return jsonify({
        "resultMessage": {
            "en": "Successfully retrieved meal plan",
            "vn": "Lấy kế hoạch ăn thành công"
        },
        "resultCode": "00228",
        "meal_plan": result
    }), 200


@meal_api.route("/<group_id>", methods=["PATCH"])
@JWT_required
@group_admin_required
@validate_fields(["meal_id"])
@check_meal_plan_ownership
def mark_meal_plan(user_id, group_id):
    meal_plan_service = MealPlanService()
    meal_id = request.json["meal_id"]
    result = meal_plan_service.mark_meal_plan(meal_id)

    if result == "meal plan not found":
        return jsonify({
            "resultMessage": {
                "en": "Meal plan not found",
                "vn": "Không tìm thấy kế hoạch bữa ăn với ID này"
            },
            "resultCode": "00229"
        }), 404

    return jsonify({
        "resultMessage": {
            "en": "Meal plan status changed successfully",
            "vn": "Thay đổi trạng thái kế hoạch ăn thành công"
        }
    }), 200


@meal_api.route("/<group_id>", methods=["DELETE"])
@JWT_required
@group_admin_required
@validate_fields(["meal_id"])
@check_meal_plan_ownership
def delete_meal_plan(user_id, group_id):
    meal_plan_service = MealPlanService()
    meal_id = request.json["meal_id"]
    result = meal_plan_service.delete_meal_plan(meal_id)

    if result == "meal plan not found":
        return jsonify({
            "resultMessage": {
                "en": "Meal plan not found",
                "vn": "Không tìm thấy kế hoạch bữa ăn với ID này"
            },
            "resultCode": "00229"
        }), 404

    return jsonify({
        "resultMessage": {
            "en": "Meal plan deleted successfully",
            "vn": "Xóa kế hoạch ăn thành công"
        }
    }), 200
