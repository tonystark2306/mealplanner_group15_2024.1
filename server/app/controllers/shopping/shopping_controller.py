from flask import request, jsonify


from . import shopping_api
from ...services.shopping.shopping_list_service import ShoppingListService
# from ...services.shopping.shopping_task_service import ShoppingTaskService
from ...services.user.group_service import GroupService
from ...utils.decorator import JWT_required, group_member_required, group_admin_required
from ...utils.middleware import check_list_ownership, validate_fields



@shopping_api.route("/<group_id>", methods=["POST"])
@JWT_required
@group_admin_required
@validate_fields(["name"])
def create_shopping_list(user_id, group_id):
    '''Create shopping list'''

    data = request.json
    data['group_id'] = group_id
    list_service = ShoppingListService()
    result = list_service.create_shopping_list(data)
    
    if result == "user not found":
        return jsonify({
            "resultMessage": {
                "en": "User assigned name does not exist.",
                "vn": "Tên người dùng được gán không tồn tại."
            },
            "resultCode": "00245"
        }), 404
    
    if result == "not a member":
        return jsonify({
            "resultMessage": {
                "en": "Cannot assign user who is not a member of the group.",
                "vn": "Không thể gán người dùng không phải là thành viên của nhóm."
            },
            "resultCode": "00246"
        }), 403
    
    return jsonify({

        "resultMessage": {
            "en": "Shopping list created successfully.",
            "vn": "Danh sách mua sắm được tạo thành công."
        },
        "resultCode": "00249",
        "created_shopping_list": result
    }), 201


@shopping_api.route("/<group_id>", methods=["PUT"])
@JWT_required
@group_admin_required
@validate_fields(["list_id"])
@check_list_ownership
def update_shopping_list(user_id, group_id):
    '''Update shopping list''' 
    list_service = ShoppingListService()

    
    data = request.json
    data['group_id'] = group_id
    result = list_service.update_shopping_list(data)

    if result == "user not found":
        return jsonify({
            "resultMessage": {
                "en": "User assigned name does not exist.",
                "vn": "Tên người dùng được gán không tồn tại."
            },
            "resultCode": "00245"
        }), 404
    
    if result == "not a member":
        return jsonify({
            "resultMessage": {
                "en": "Cannot assign user who is not a member of the group.",
                "vn": "Không thể gán người dùng không phải là thành viên của nhóm."
            },
            "resultCode": "00246"
        }), 403
    
    return jsonify({
        "resultMessage": {
            "en": "Shopping list updated successfully.",
            "vn": "Danh sách mua sắm được cập nhật thành công."
        },
        "resultCode": "00266",
        "updated_shopping_list": result
    }), 200

    
@shopping_api.route("/<group_id>", methods=["DELETE"])
@JWT_required
@group_admin_required
@check_list_ownership
def delete_shopping_list(user_id, group_id):
    '''Delete shopping list'''
    list_id = request.json.get("list_id")
    list_service = ShoppingListService()
    
    result = list_service.change_status(group_id, list_id, "Deleted")
    return jsonify({
        "resultMessage": {
            "en": "Shopping list deleted successfully.",
            "vn": "Danh sách mua sắm được xóa thành công."
        },
        "resultCode": "00267",
    }), 200


@shopping_api.route("/<group_id>", methods=["GET"])
@JWT_required
@group_member_required
def get_shopping_lists(user_id, group_id):
    '''Get shopping lists
    if user is admin, return all
    if user is not admin, return only assigned lists
    '''
    list_service = ShoppingListService()
    lists = list_service.get_shopping_lists(group_id, user_id)
    return jsonify({
        "resultMessage": {
            "en": "Successfully retrieved shopping lists.",
            "vn": "Lấy danh sách mua sắm thành công."
        },
        "shopping_lists": lists,
        "resultCode": "00250"
    }), 200



