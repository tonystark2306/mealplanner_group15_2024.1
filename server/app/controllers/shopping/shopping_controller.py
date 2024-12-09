from flask import request, jsonify


from . import shopping_api
from ...services.shopping.shopping_list_service import ShoppingListService
# from ...services.shopping.shopping_task_service import ShoppingTaskService
from ...services.user.group_service import GroupService
from ...utils.decorator import JWT_required, group_member_required, validate_fields



@shopping_api.route("/<group_id>", methods=["POST"])
@JWT_required
@group_member_required
@validate_fields(["name"])
def create_shopping_list(user_id, group_id):

    group_service = GroupService()
    #Only group admin can create shopping list
    is_admin = group_service.is_admin(user_id, group_id)
    if not is_admin:
        return jsonify({
            "resultMessage": {
                "en": "User is not a group admin",
                "vn": " Người dùng không phải là quản trị viên nhóm"
            },
            "resultCode": "00258"
        }), 403

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

