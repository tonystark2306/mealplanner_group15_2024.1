from flask import request, jsonify

from . import fridge_api
from ...services.fridge.fridge_service import FridgeService
from ...utils.decorator import JWT_required, group_member_required
from ...utils.middleware import check_item_ownership, validate_fields


@fridge_api.route("/<group_id>", methods=["GET"])
@JWT_required
@group_member_required
def get_group_fridge(user_id, group_id):
    fridge_service = FridgeService()
    fridge = fridge_service.get_group_fridge(group_id)

    return jsonify({
        "resultMessage": {
            "en": "Successfully retrieved fridge items list",
            "vn": "Lấy danh sách đồ tủ lạnh thành công"
        },
        "resultCode": "00228",
        "fridgeItems": fridge
    }), 200


@fridge_api.route("/<group_id>", methods=["POST"])
@JWT_required
@group_member_required
@validate_fields({"foodName", "quantity", "expiration_date"})
def create_fridge_item(user_id, group_id):
    fridge_service = FridgeService()
    data = request.json

    data["owner_id"] = group_id
    data["added_by"] = user_id
    result = fridge_service.add_item_to_fridge(data)
    if result == "food not found":
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
        "resultCode": "00202",
        "fridge_item": result
    }), 201


@fridge_api.route("/<group_id>/<item_id>", methods=["GET"])
@JWT_required
@group_member_required
@check_item_ownership
def get_specific_item(user_id, group_id, item_id):
    fridge_service = FridgeService()
    fridge_item = fridge_service.get_specific_item(item_id)
    if fridge_item == "food not found":
        return jsonify({
            "resultMessage": {
                "en": "No food item found with provided name",  
                "vn": "Không tìm thấy thực phẩm với tên đã cung cấp"
            },
            "resultCode": "00230"
        }), 404
    if fridge_item == "item not found":
        return jsonify({
            "resultMessage": {
                "en": "Fridge item linked to this food item has not been created",
                "vn": "Mục trong tủ lạnh liên kết với thực phẩm này chưa được tạo"
            },
            "resultCode": "00234"
        }), 404
    return jsonify({
        "resultMessage": {
            "en": "Successfully retrieved fridge item",
            "vn": "Lấy thông tin thực phẩm trong tủ lạnh thành công"
        },
        "resultCode": "00229",
        "fridgeItem": fridge_item
    }), 200


@fridge_api.route("/<group_id>", methods=["PUT"])
@JWT_required
@group_member_required
@validate_fields({"itemId", "newFoodName", "newQuantity", "newExpiration_date"})
@check_item_ownership
def update_fridge_item(user_id, group_id):
    fridge_service = FridgeService()
    data = request.json
    data["owner_id"] = group_id
    data["added_by"] = user_id

    
    result = fridge_service.update_fridge_item(data)
    if result == "item not found":
        return jsonify({
            "resultMessage": {
                "en": "Fridge item not found.",
                "vn": "Không tìm thấy mục trong tủ lạnh."
            },
            "resultCode": "00233"
        }), 404
    return jsonify({
        "resultMessage": {
            "en": "Fridge item updated successfully.",
            "vn": "Cập nhật mục trong tủ lạnh thành công."
        },
        "resultCode": "00216",
        "updated_fridge_item": result
    }), 200


@fridge_api.route("/<group_id>/<item_id>", methods=["DELETE"])
@JWT_required
@group_member_required
@check_item_ownership
def delete_fridge_item(user_id, group_id, item_id):
    fridge_service = FridgeService()
    result = fridge_service.delete_fridge_item(item_id)
    if result == "item not found":
        return jsonify({
            "resultMessage": {
                "en": "Fridge item not found.",
                "vn": "Không tìm thấy mục trong tủ lạnh."
            },
            "resultCode": "00233"
        }), 404
    return jsonify({
        "resultMessage": {
            "en": "Fridge item deleted successfully.",
            "vn": "Xóa mục trong tủ lạnh thành công."
        },
        "resultCode": "00224"
    }), 200