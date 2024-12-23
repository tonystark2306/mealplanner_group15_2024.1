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
    existed_food = food_service.get_food_in_group_by_name(group_id, data["name"])
    if existed_food:
        return jsonify({
            "resultMessage": {
                "en": "Food with provided name already exists in this group.",
                "vn": "Thực phẩm với tên cung cấp đã tồn tại trong nhóm này."
            },
            "resultCode": "00034"
        }), 400

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
    
    
@food_api.route("/group/<group_id>", methods=["PUT"])
@JWT_required
def update_food(user_id, group_id):
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
    new_image_file = request.files.get("image")
    if not data and not new_image_file:
        return jsonify({
            "resultMessage": {
                "en": "No data provided!",
                "vn": "Không tìm thấy dữ liệu nào được cung cấp!"
            },
            "resultCode": "00004"
        }), 400
        
    food_name = data.get("name")
    if not food_name:
        return jsonify({
            "resultMessage": {
                "en": "Please provide food name.",
                "vn": "Vui lòng cung cấp tên thực phẩm."
            },
            "resultCode": "00035"
        }), 400
        
    food_service = FoodService()
    food_to_update = food_service.get_food_in_group_by_name(group_id, food_name)
    if not food_to_update:
        return jsonify({
            "resultMessage": {
                "en": "Food with provided name not found in this group.",
                "vn": "Thực phẩm với tên cung cấp không tồn tại trong nhóm này."
            },
            "resultCode": "00036"
        }), 404
        
    if data:
        ALLOW_FIELDS = {"name", "newType", "newUnitName", "newFoodCategoryNames", "newNote"}
        unknown_fields = {field for field in data if field not in ALLOW_FIELDS}
        if unknown_fields:
            return jsonify({
                "resultMessage": {
                    "en": f"Unknown fields: {', '.join(unknown_fields)}",
                    "vn": f"Các trường không xác định: {', '.join(unknown_fields)}"
                },
                "resultCode": "00003"
            }), 400
            
    updated_food = food_service.update_food_info(food_to_update, data, new_image_file)
    return jsonify({
        "resultMessage": {
            "en": "Successful",
            "vn": "Thành công"
        },
        "resultCode": "00178",
        "food": updated_food.as_dict()
    }), 200


@food_api.route("/group/<group_id>", methods=["DELETE"])
@JWT_required
def delete_food(user_id, group_id):
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
                "en": "No data provided!",
                "vn": "Không tìm thấy dữ liệu nào được cung cấp!"
            },
            "resultCode": "00004"
        }), 400
        
    food_name = data.get("name")
    if not food_name:
        return jsonify({
            "resultMessage": {
                "en": "Please provide food name.",
                "vn": "Vui lòng cung cấp tên thực phẩm."
            },
            "resultCode": "00035"
        }), 400
        
    food_service = FoodService()
    food_to_delete = food_service.get_food_in_group_by_name(group_id, food_name)
    if not food_to_delete:
        return jsonify({
            "resultMessage": {
                "en": "Food with provided name not found in this group.",
                "vn": "Thực phẩm với tên cung cấp không tồn tại trong nhóm này."
            },
            "resultCode": "00036"
        }), 404
        
    food_service.delete_food_from_db(food_to_delete)
    return jsonify({
        "resultMessage": {
            "en": "Food deletion successfull",
            "vn": "Xóa thực phẩm thành công"
        },
        "resultCode": "00184"
    }), 200
    
    
@food_api.route("/group/<group_id>", methods=["GET"])
@JWT_required
def get_all_foods_in_group(user_id, group_id):
    group_service = GroupService()
    if not group_service.is_member_of_group(user_id, group_id):
        return jsonify({
            "resultMessage": {
                "en": "You are not a member of this group.",
                "vn": "Bạn không phải là thành viên của nhóm này."
            },
            "resultCode": "00031"
        }), 403
        
    food_service = FoodService()
    foods = food_service.get_all_foods_in_group(group_id)
    return jsonify({
        "resultMessage": {
            "en": "Successful",
            "vn": "Thành công"
        },
        "resultCode": "00185",
        "foods": foods
    }), 200