from flask import request, jsonify
from flasgger.utils import swag_from

from . import admin_api
from ...services.admin.unit_service import UnitService
from ...utils.decorator import JWT_required, system_admin_required


@admin_api.route("/unit", methods=["POST"])
@JWT_required
@system_admin_required
@swag_from(
    "../../docs/admin/unit/create_system_unit.yaml", 
    endpoint="admin_api.create_system_unit", 
    methods=["POST"]
)
def create_system_unit(user_id):
    data = request.get_json()
    if data is None:
        return jsonify({
            "resultMessage": {
                "en": "Invalid JSON data.",
                "vn": "Dữ liệu JSON không hợp lệ."
            },
            "resultCode": "00004"
        }), 400
    
    unit_name = data.get("unitName")
    if not unit_name:
        return jsonify({
            "resultMessage": {
                "en": "Missing unit name information",
                "vn": "Thiếu thông tin tên của đơn vị"
            },
            "resultCode": "00112"
        }), 400
    
    unit_service = UnitService()
    existed_unit = unit_service.get_unit_by_name(unit_name)
    if existed_unit:
        return jsonify({
            "resultMessage": {
                "en": "Unit with this name already exists",
                "vn": "Đã tồn tại đơn vị có tên này"
            },
            "resultCode": "00113"
        }), 400
    
    new_unit = unit_service.create_unit_for_system(unit_name)
    return jsonify({
        "resultMessage": {
            "en": "Unit created successfully",
            "vn": "Tạo đơn vị thành công"
        },
        "resultCode": "00116",
        "unit": new_unit.as_dict()
    }), 201


@admin_api.route("/unit", methods=["GET"])
@JWT_required
@swag_from(
    "../../docs/admin/unit/get_all_system_unit.yaml", 
    endpoint="admin_api.get_all_system_unit", 
    methods=["GET"]
)
def get_all_system_unit():
    unit_service = UnitService()
    units = unit_service.list_system_units()
    return jsonify({
        "resultMessage": {
            "en": "Get all units successfully",
            "vn": "Lấy các unit thành công"
        },
        "resultCode": "00110",
        "units": [unit.as_dict() for unit in units]
    }), 200
    
    
@admin_api.route("/unit", methods=["PUT"])
@JWT_required
@system_admin_required
@swag_from(
    "../../docs/admin/unit/update_system_unit_name.yaml", 
    endpoint="admin_api.update_system_unit_name", 
    methods=["PUT"]
)
def update_system_unit_name(user_id):
    data = request.get_json()
    if data is None:
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
                "en": "Missing old name, new name information",
                "vn": "Thiếu thông tin name cũ, name mới"
            },
            "resultCode": "00117"
        }), 400
        
    unit_service = UnitService()
    unit_to_update = unit_service.get_unit_by_name(old_name)
    if not unit_to_update:
        return jsonify({
            "resultMessage": {
                "en": "Unit with this name not found",
                "vn": "Không tìm thấy đơn vị với tên cung cấp"
            },
            "resultCode": "00119"
        }), 404
        
    existed_unit = unit_service.get_unit_by_name(new_name)
    if existed_unit:
        return jsonify({
            "resultMessage": {
                "en": "Unit with new name already exists",
                "vn": "Đã tồn tại đơn vị với tên mới này"
            },
            "resultCode": "00113"
        }), 400
        
    unit_service.update_unit_name(unit_to_update, new_name)
    return jsonify({
        "resultMessage": {
            "en": "Unit name updated successfully",
            "vn": "Sửa đổi đơn vị thành công"
        },
        "resultCode": "00122"
    }), 200
    
    
@admin_api.route("/unit", methods=["DELETE"])
@JWT_required
@system_admin_required
@swag_from(
    "../../docs/admin/unit/delete_system_unit_by_name.yaml", 
    endpoint="admin_api.delete_system_unit_by_name", 
    methods=["DELETE"]
)
def delete_system_unit_by_name(user_id):
    data = request.get_json()
    if not data:
        return jsonify({
            "resultMessage": {
                "en": "Invalid JSON data.",
                "vn": "Dữ liệu JSON không hợp lệ."
            },
            "resultCode": "00004"
        }), 400
    
    unit_name = data.get("unitName")
    if not unit_name:
        return jsonify({
            "resultMessage": {
                "en": "Missing unit name information",
                "vn": "Thiếu thông tin tên của đơn vị"
            },
            "resultCode": "00112"
        }), 400
    
    unit_service = UnitService()
    unit_to_delete = unit_service.get_unit_by_name(unit_name)
    if not unit_to_delete:
        return jsonify({
            "resultMessage": {
                "en": "Unit with this name not found",
                "vn": "Không tìm thấy đơn vị với tên cung cấp"
            },
            "resultCode": "00119"
        }), 404
        
    unit_service.delete_unit(unit_to_delete)
    return jsonify({
        "resultMessage": {
            "en": "Unit deleted successfully",
            "vn": "Xóa đơn vị thành công"
        },
        "resultCode": "00128"
    }), 200