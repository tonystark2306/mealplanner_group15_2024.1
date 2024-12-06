import logging

from flask import request, jsonify

from . import user_api
from ...services.user.edit_service import EditService
from ...services.user.auth_service import AuthService
from ...utils.decorator import JWT_required


@user_api.route("/change-password", methods=["POST"])
@JWT_required
def change_password(user):
    data = request.get_json()
    if data is None:
        return jsonify({
            "resultMessage": {
                "en": "Invalid JSON data.",
                "vn": "Dữ liệu JSON không hợp lệ."
            },
            "resultCode": "00004"
        }), 400
    
    old_password = data.get("oldPassword")
    new_password = data.get("newPassword")
    
    if not old_password or not new_password:
        return jsonify({
            "resultMessage": {
                "en": "Please provide all required fields!",
                "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
            },
            "resultCode": "00025"
        }), 400
        
    if old_password == new_password:
        return jsonify({
            "resultMessage": {
                "en": "Your new password should not be the same as your old password, please try another password.",
                "vn": "Mật khẩu mới của bạn không nên giống với mật khẩu cũ, vui lòng thử một mật khẩu khác."
            },
            "resultCode": "00073"
        }), 400
        
    auth_service = AuthService()
    if not auth_service.validate_password(new_password):
        return jsonify({
            "resultMessage": {
                "en": "Please provide both old and new passwords longer than 6 characters and shorter than 20 characters.",
                "vn": "Vui lòng cung cấp mật khẩu cũ và mới dài hơn 6 ký tự và ngắn hơn 20 ký tự."
            },
            "resultCode": "00069"
        }), 400
        
    edit_service = EditService()
    if not edit_service.verify_old_password(user, old_password):
        return jsonify({
            "resultMessage": {
                "en": "Your old password does not match the password you entered, please enter the correct password.",
                "vn": "Mật khẩu cũ của bạn không khớp với mật khẩu bạn nhập, vui lòng nhập mật khẩu đúng."
            },
            "resultCode": "00072"
        }), 400
        
    edit_service.save_new_password(user, new_password)
    return jsonify({
        "resultMessage": {
            "en": "Your password was changed successfully.",
            "vn": "Mật khẩu của bạn đã được thay đổi thành công."
        },
        "resultCode": "00076"
    }), 200
        
        
@user_api.route("/", methods=["PUT"])
@JWT_required
def edit_user(user):
    data = request.form
    avatar_file = request.files.get("image")
    if not data and not avatar_file:
        return jsonify({
            "resultMessage": {
                "en": "No data provided!",
                "vn": "Không tìm thấy dữ liệu nào được cung cấp!"
            },
            "resultCode": "00004"
        }), 400
    
    if data:
        ALLOW_FIELDS = {"username", "name", "language", "timezone", "deviceId"}
        unknown_fields = {field for field in data if field not in ALLOW_FIELDS}
        if unknown_fields:
            return jsonify({
                "resultMessage": {
                    "en": f"Unknown fields: {', '.join(unknown_fields)}",
                    "vn": f"Các trường không xác định: {', '.join(unknown_fields)}"
                },
                "resultCode": "00003"
            }), 400
        
    auth_service = AuthService()
    if data.get("username") and auth_service.is_duplicated_username(data["username"]):
        return jsonify({
            "resultMessage": {
                "en": "This username is already in use, please choose another username.",
                "vn": "Username này đã được sử dụng, vui lòng chọn username khác."
            },
            "resultCode": "00071"
        }), 400
    
    edit_service = EditService()
    updated_user = edit_service.update_user_info(user, data, avatar_file)
    return jsonify({
        "resultMessage": {
            "en": "Your profile information was changed successfully.",
            "vn": "Thông tin hồ sơ của bạn đã được thay đổi thành công."
        },
        "resultCode": "00086",
        "updatedUser": updated_user.to_json()
    }), 200