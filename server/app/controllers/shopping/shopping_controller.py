from flask import request, jsonify
from flasgger.utils import swag_from

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
@swag_from(
    "../../docs/shopping/shopping/create_shopping_list.yaml", 
    endpoint="shopping_api.create_shopping_list", 
    methods=["POST"]
)
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
@swag_from(
    "../../docs/shopping/shopping/update_shopping_list.yaml", 
    endpoint="shopping_api.update_shopping_list", 
    methods=["PUT"]
)
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
@swag_from(
    "../../docs/shopping/shopping/delete_shopping_list.yaml", 
    endpoint="shopping_api.delete_shopping_list", 
    methods=["DELETE"]
)
def delete_shopping_list(user_id, group_id):
    '''Delete shopping list'''
    list_id = request.json.get("list_id")
    list_service = ShoppingListService()
    
    result = list_service.change_status(group_id, list_id, "Deleted")

    if result:
        if result["status"] == "Deleted":
            return jsonify({
                "resultMessage": {
                    "en": "Shopping list deleted successfully.",
                    "vn": "Danh sách mua sắm được xóa thành công."
                },
                "resultCode": "00267",
            }), 200
        
    return jsonify({
        "resultMessage": {
            "en": "Cannot delete shopping list.",
            "vn": "Không xoá được danh sách mua sắm, hãy thử lại."
        },
        "resultCode": "00268"
    }), 404


@shopping_api.route("/<group_id>", methods=["GET"])
@JWT_required
@group_member_required
@swag_from(
    "../../docs/shopping/shopping/get_shopping_lists.yaml", 
    endpoint="shopping_api.get_shopping_lists", 
    methods=["GET"]
)
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


@shopping_api.route("/<group_id>/mark", methods=["PUT"])
@JWT_required
@group_admin_required
@check_list_ownership
@swag_from(
    "../../docs/shopping/shopping/mark_list.yaml", 
    endpoint="shopping_api.mark_list", 
    methods=["PUT"]
)
def mark_list(user_id, group_id):
    '''Mark shopping list as completed'''
    list_id = request.json.get("list_id")
    list_service = ShoppingListService()
    result = list_service.mark_list(group_id, list_id)

    if result == "list not found":
        return jsonify({
            "resultMessage": {
                "en": "Shopping list not found.",
                "vn": "Không tìm thấy danh sách mua sắm."
            },
            "resultCode": "00296"
        }), 404
    
    return jsonify({
        "resultMessage": {
            "en": result["en"],
            "vn": result["vn"]
        },
        "resultCode": "00299"
    }), 200
