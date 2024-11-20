import logging

from flask import request, jsonify
from validate_email_address import validate_email

from . import user_api
from ...services.user.auth_service import (
    validate_login,
    generate_access_token,
    generate_refresh_token
)


@user_api.route("/login", methods=["POST"])
def login():
    try:
        data = request.get_json()
        if data is None:
            raise ValueError("Dữ liệu JSON không hợp lệ.")
        
        email = data.get("email")
        password = data.get("password")
        
        if email is None or password is None:
            return jsonify({
                "resultMessage": {
                    "en": "Please provide all required fields!",
                    "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
                },
                "resultCode": "00025"
            }), 400
            
        if not validate_email(email):
            return jsonify({
                "resultMessage": {
                    "en": "Please provide a valid email address!",
                    "vn": "Vui lòng cung cấp một địa chỉ email hợp lệ!"
                },
                "resultCode": "00026"
            }), 400

        user = validate_login(email, password)
        
        if not user:
            return jsonify({
                "resultMessage": {
                    "en": "You have entered an invalid email or password.",
                    "vn": "Bạn đã nhập một email hoặc mật khẩu không hợp lệ."
                },
                "resultCode": "00045"
            }), 400
            
        access_token = generate_access_token(user.id)
        refresh_token = generate_refresh_token(user.id)

        return jsonify({
            "resultMessage": {
                "en": "You have successfully logged in.",
                "vn": "Bạn đã đăng nhập thành công."
            },
            "resultCode": "00047",
            "user": user.to_json(),
            "access_token": access_token,
            "refresh_token": refresh_token
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