from flask import request, jsonify

from . import admin_api
from ...services.admin.category_service import CategoryService
from ...utils.decorator import JWT_required, system_admin_required


@admin_api.route("/category", methods=["POST"])
@JWT_required
@system_admin_required
def create_system_category(user_id):
    data = request.get_json()
    if data is None:
        return jsonify({
            "resultMessage": {
                "en": "Invalid JSON data.",
                "vn": "Dữ liệu JSON không hợp lệ."
            },
            "resultCode": "00004"
        }), 400
    
    category_name = data.get("name")
    if not category_name:
        return jsonify({
            "resultMessage": {
                "en": "Please provide all required fields!",
                "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
            },
            "resultCode": "00025"
        }), 400
    
    category_service = CategoryService()
    new_category = category_service.create_category_for_system(category_name)
    return jsonify({
        "resultMessage": {
            "en": "Category created successfully",
            "vn": "Tạo category thành công"
        },
        "resultCode": "00135",
        "category": new_category.as_dict()
    }), 201


@admin_api.route("/category", methods=["GET"])
@JWT_required
@system_admin_required
def get_all_system_categories(user_id):
    category_service = CategoryService()
    categories = category_service.list_system_categories()
    return jsonify({
        "resultMessage": {
            "en": "Successfully retrieved categories",
            "vn": "Lấy các category thành công"
        },
        "resultCode": "00129",
        "categories": [category.as_dict() for category in categories]
    }), 200
    
    
@admin_api.route("/category", methods=["PUT"])
@JWT_required
@system_admin_required
def update_category_name(user_id):
    data = request.get_json()
    if not data:
        return jsonify({
            "resultMessage": {
                "en": "Invalid JSON data.",
                "vn": "Dữ liệu JSON không hợp lệ."
            },
            "resultCode": "00004"
        }), 400
        
    old_name = data.get("oldName")
    new_name = data.get("newName")
    if not old_name or not new_name:
        return jsonify({
            "resultMessage": {
                "en": "Please provide all required fields!",
                "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
            },
            "resultCode": "00025"
        }), 400
        
    category_service = CategoryService()
    category_to_update = category_service.get_category_by_name(old_name)
    if not category_to_update:
        return jsonify({
            "resultMessage": {
                "en": "Category not found with provided name",
                "vn": "Không tìm thấy category với tên cung cấp"
            },
            "resultCode": "00138"
        }), 404
        
    category_service.update_category_name(category_to_update, new_name)
    return jsonify({
        "resultMessage": {
            "en": "Category modification successful",
            "vn": "Sửa đổi category thành công"
        },
        "resultCode": "00141"
    }), 200