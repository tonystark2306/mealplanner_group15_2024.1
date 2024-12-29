from flask import request, jsonify


from . import shopping_api
from ...services.shopping.shopping_list_service import ShoppingListService
from ...services.shopping.shopping_task_service import ShoppingTaskService
# from ...services.shopping.shopping_task_service import ShoppingTaskService
from ...services.user.group_service import GroupService
from ...utils.decorator import JWT_required, group_member_required, group_admin_required
from ...utils.middleware import validate_fields, check_task_ownership, check_list_ownership


@shopping_api.route("/<group_id>/task", methods=["POST"])
@JWT_required
@group_admin_required
@validate_fields(["list_id", "tasks"])
@check_list_ownership
def create_tasks(user_id, group_id):
    '''Create shopping task'''
    data = request.json
    data['group_id'] = group_id

    task_service = ShoppingTaskService()
    result = task_service.create_tasks(data)

    if result == "list not found":
        return jsonify({
            "resultMessage": {
                "en": "Shopping list not found.",
                "vn": "Không tìm thấy danh sách mua sắm."
            },
            "resultCode": "00283"
        }), 404
    
    if result == "list is cancelled":
        return jsonify({
            "resultMessage": {
                "en": "Cannot add task to cancelled shopping list.",
                "vn": "Không thể thêm task vào danh sách mua sắm đã hủy."
            },
            "resultCode": "00284"
        }), 400
    
    if result == "food not found":
        return jsonify({
            "resultMessage": {
                "en": "Food not found.",
                "vn": "Không tìm thấy một món ăn với tên cung cấp trong mảng."
            },
            "resultCode": "00285"
        }), 404
    
    if result == "food already exists, merged successfully":
        return jsonify({
            "resultMessage": {
                "en": "Food already exists, merged successfully.",
                "vn": " Thực phẩm này đã có trong danh sách, nhiệm vụ đã được gộp."
            },
            "resultCode": "00285x"
        }), 400
    
    if result == "quantity must be a number":
        return jsonify({
            "resultMessage": {
                "en": "Quantity must be a number.",
                "vn": "Số lượng phải là một số."
            },
            "resultCode": "00286"
        }), 400
    
    return jsonify({
        "resultMessage": {
            "en": "Successfully added tasks.",
            "vn": "Thêm các nhiệm vụ thành công."
        },
        "resultCode": "00287"
    }), 201


@shopping_api.route("/<group_id>/task", methods=["GET"])
@JWT_required
@group_member_required
@check_list_ownership
def get_tasks(user_id, group_id):
    '''Get tasks of a shopping list'''
    list_id = request.args.get("list_id")
    if not list_id:
        return jsonify({
            "resultMessage": {
                "en": "List ID is required.",
                "vn": "ID danh sách mua sắm là bắt buộc."
            },
            "resultCode": "00292"
        }), 400
    task_service = ShoppingTaskService()

    result = task_service.get_tasks_of_list(list_id, group_id, user_id)

    if result == "list not found":
        return jsonify({
            "resultMessage": {
                "en": "Shopping list not found.",
                "vn": "Không tìm thấy danh sách mua sắm."
            },
            "resultCode": "00283"
        }), 404
    if result == "you are not allowed to access this list":
        return jsonify({
            "resultMessage": {
                "en": "You are not allowed to access this list.",
                "vn": "Bạn không được phép truy cập danh sách này."
            },
            "resultCode": "00293"
        }), 403
    
    return jsonify({
        "resultMessage": {
            "en": "Successfully retrieved tasks.",
            "vn": "Lấy danh sách nhiệm vụ thành công."
        },
        "resultCode": "00294",
        "tasks": result
    }), 200


@shopping_api.route("/<group_id>/task", methods=["PUT"])
@JWT_required
@group_admin_required
@check_list_ownership
@validate_fields(["list_id","task_id", "new_food_name", "new_quantity"])
def update_task(user_id, group_id):
    '''Update shopping task'''
    data = request.json
    data['group_id'] = group_id

    task_service = ShoppingTaskService()
    result = task_service.update_task(data)

    if result == "task not found":
        return jsonify({
            "resultMessage": {
                "en": "Task not found.",
                "vn": "Không tìm thấy nhiệm vụ với ID đã cung cấp."
            },
            "resultCode": "00288"
        }), 404
    
    if result == "food not found":
        return jsonify({
            "resultMessage": {
                "en": "Food not found.",
                "vn": "Vui lòng cung cấp một new_food_name hợp lệ."
            },
            "resultCode": "00289"
        }), 404
    
    if result == "quantity must be a number":
        return jsonify({
            "resultMessage": {
                "en": "Quantity must be a number.",
                "vn": "new_quantity phải là một số."
            },
            "resultCode": "00290"
        }), 400
    
    if result == "task is cancelled or completed":
        return jsonify({
            "resultMessage": {
                "en": "Cannot update cancelled or completed task.",
                "vn": "Không thể cập nhật nhiệm vụ đã hủy hoặc đã hoàn thành."
            },
            "resultCode": "00291."
        }), 400
    
    if result == "task merged successfully":
        return jsonify({
            "resultMessage": {
                "en": "Task merged successfully.",
                "vn": "Thực phẩm này đã có trong danh sách, nhiệm vụ đã được gộp."
            },
            "resultCode": "00309"
        }), 200
    
    return jsonify({
        "resultMessage": {
            "en": "Task updated successfully.",
            "vn": "Cập nhật nhiệm vụ thành công."
        },
        "resultCode": "00312"
    }), 200


@shopping_api.route("/<group_id>/task", methods=["DELETE"])
@JWT_required
@group_admin_required
@check_list_ownership
def delete_task(user_id, group_id):
    '''Delete shopping task'''
    list_id = request.json.get("list_id")
    task_id = request.json.get("task_id")
    task_service = ShoppingTaskService()
    result = task_service.delete_task(list_id, task_id)

    if result == "task not found":
        return jsonify({
            "resultMessage": {
                "en": "Task not found.",
                "vn": "Không tìm thấy nhiệm vụ với ID đã cung cấp."
            },
            "resultCode": "00296"
        }), 404
    
    if isinstance(result, dict) and 'en' in result and "Cannot change status" in result['en']:
        return jsonify({
            "resultMessage": {
                "en": result['en'],
                "vn": result['vn']
            },
            "resultCode": "00313"
        }), 400
    
    return jsonify({
        "resultMessage": {
            "en": "Task deleted successfully.",
            "vn": "Xóa nhiệm vụ thành công."
        },
        "resultCode": "00299"
    }), 200


@shopping_api.route("/<group_id>/task/mark", methods=["PUT"])
@JWT_required
@group_member_required
@check_list_ownership
def mark_task(user_id, group_id):
    '''Mark shopping task as completed'''
    list_id = request.json.get("list_id")
    task_id = request.json.get("task_id")
    task_service = ShoppingTaskService()
    result = task_service.mark_task(list_id, task_id)

    if result == "task not found":
        return jsonify({
            "resultMessage": {
                "en": "Task not found.",
                "vn": "Không tìm thấy nhiệm vụ với ID đã cung cấp."
            },
            "resultCode": "00296"
        }), 404
    
    #nếu kết quả trả về là dict thì kiểm tra key "Cannot change status" trong result['en']
    if isinstance(result, dict) and 'en' in result and "Cannot change status" in result['en']:
        return jsonify({
            "resultMessage": {
                "en": result['en'],
                "vn": result['vn']
            },
            "resultCode": "00313"
        }), 400
    
    return jsonify({
        "resultMessage": {
            "en": "Task marked successfully.",
            "vn": "Thay đổi trạng thái nhiệm vụ thành công."
        },
        "resultCode": "00314"
    }), 200
