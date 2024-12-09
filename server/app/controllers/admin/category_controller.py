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
   