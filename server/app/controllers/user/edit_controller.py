import logging

from flask import request, jsonify
from validate_email_address import validate_email

from . import user_api
from ...services.user.edit_service import EditService
from ...services.user.auth_service import validate_password
from ...email import send_email
from ...utils.decorator import JWT_required


@user_api.route("/change-password", methods=["POST"])
@JWT_required
def change_password(user):
    try:
        data = request.get_json()
        if data is None:
            raise ValueError("Dữ liệu JSON không hợp lệ.")
        
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
            
        if not validate_password(new_password):
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
        
    except ValueError:
        return jsonify({
            "resultMessage": {
                "en": "Invalid JSON data.",
                "vn": "Dữ liệu JSON không hợp lệ."
            },
            "resultCode": "00004"
        }), 400
        
    except Exception as e:
        logging.error(f"Internal server error: {str(e)}")
        return jsonify({
            "resultMessage": {
                "en": "An internal server error has occurred, please try again.",
                "vn": "Đã xảy ra lỗi máy chủ nội bộ, vui lòng thử lại."
            },
            "resultCode": "00008"
        }), 500