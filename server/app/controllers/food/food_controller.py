from flask import request, jsonify
from flasgger.utils import swag_from

from . import food_api
from ...services.food.food_service import FoodService
from ...services.user.group_service import GroupService
from ...utils.decorator import JWT_required


@food_api.route("/group/<group_id>", methods=["POST"])
@JWT_required
def add_food(user_id, group_id):
    group_service = GroupService()
    if not group_service.is_member_of_group(user_id, group_id):
        return jsonify({
            "resultMessage": {
                "en": "You are not a member of this group.",
                "vn": "Bạn không phải là thành viên của nhóm này."
            },
            "resultCode": "00031"
        }), 403

    data = request.form
    if not data:
        return jsonify({
            "resultMessage": {
                "en": "Invalid request data.",
                "vn": "Dữ liệu yêu cầu không hợp lệ."
            },
            "resultCode": "00033"
        }), 400
    
    image_file = request.files.get("image")
    REQUIRED_FIELDS = {"name", "type", "foodCategoryNames", "unitName", "note"}
    missing_fields = [field for field in REQUIRED_FIELDS if field not in data]
    if not image_file or missing_fields:
        return jsonify({
            "resultMessage": {
                "en": "Please provide all required fields!",
                "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
            },
            "resultCode": "00025"
        }), 400
        
    food_service = FoodService()
    new_food = food_service.save_new_food(user_id, group_id, image_file, data)
    if not new_food:
        return jsonify({
            "resultMessage": {
                "en": "Category or unit with provided name not found.",
                "vn": "Không tìm thấy category hoặc unit với tên cung cấp."
            },
            "resultCode": "00032"
        }), 404
        
    return jsonify({
        "resultMessage": {
            "en": "Food creation successful",
            "vn": "Tạo thực phẩm thành công"
        },
        "resultCode": "00160",
        "newFood": new_food.as_dict()
    }), 201