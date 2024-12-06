from flask import request, jsonify
import logging

from . import user_api
from ...services.user.fridge_service import FridgeService
from ...services.user.group_service import GroupService
from ...utils.decorator import JWT_required, group_member_required


@user_api.route("/group/<group_id>/fridge", methods=["GET"])
@JWT_required
@group_member_required
def get_group_fridge(user_id, group_id):
    fridge_service = FridgeService()
    fridge = fridge_service.get_group_fridge(group_id)
    return jsonify({
        "resultMessage": {
            "en": "Fridge items retrieved successfully.",
            "vn": "Lấy thông tin tủ lạnh thành công."
        },
        "resultCode": "00001",
        "fridge": [item.to_json() for item in fridge]
    }), 200


@user_api.route("/group/<group_id>/fridge", methods=["POST"])
@JWT_required
@group_member_required
def create_fridge_item(user_id, group_id):
    fridge_service = FridgeService()
    data = request.json
    food_name = data.get("foodName")
    quantity = data.get("quantity")
    expiration_date = data.get("expiration_date")
    
    if not food_name or not quantity or not expiration_date:
        return jsonify({
            "resultMessage": {
                "en": "Please provide all required fields!",
                "vn": " Vui lòng cung cấp tất cả các trường bắt buộc!"
            },
            "resultCode": "00099"
        }), 400
    
    result = fridge_service.add_item_to_fridge(group_id, user_id, food_name, quantity, expiration_date)
    if result == "Food item not found":
        return jsonify({
            "resultMessage": {
                "en": "Food item with provided name does not exist.",
                "vn": "Thực phẩm với tên đã cung cấp không tồn tại"
            },
            "resultCode": "00194"
        }), 404
    return jsonify({
        "resultMessage": {
            "en": "Fridge item added successfully.",
            "vn": "Thêm thực phẩm vào tủ lạnh thành công."
        },
        "resultCode": "00001",
        "fridge_item": result.to_json()
    }), 201