from flask import request, jsonify
from validate_email_address import validate_email
from flask_jwt_extended import create_access_token, create_refresh_token, get_jti
from . import user_api
# from ...email import send_email
from ...services.user_service import (
    validate_login, 
    is_email_registered,
    save_new_user,
    generate_confirm_token
)
from ...models.login_attempt import LoginAttempt


@user_api.route("/login", methods=["POST"])
def login():
    try:
        data = request.get_json()
        
        if data is None:
            raise ValueError("Dữ liệu JSON không hợp lệ")
        
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

        user = validate_login(email, password)
        
        if not user:
            return jsonify({
                "resultMessage": {
                    "en": "You have entered an invalid email or password.",
                    "vn": "Bạn đã nhập một email hoặc mật khẩu không hợp lệ."
                },
                "resultCode": "00045"
            }), 400
            

        
        access_token = create_access_token(
            identity=user.id,
            fresh=True,
            additional_claims={"type": "access"}
        )
        refresh_token = create_refresh_token(
            identity=user.id,
            additional_claims={"type": "refresh"}
        )

        return jsonify({
            "resultMessage": {
                "en": "You have successfully logged in.",
                "vn": "Bạn đã đăng nhập thành công."
            },
            "resultCode": "00047",
            "user": user.to_json(), # Return actual user info
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "Bearer"
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
        print(e)
        return jsonify({
            "resultMessage": {
                "en": "An internal server error has occurred, please try again.",
                "vn": "Đã xảy ra lỗi máy chủ nội bộ, vui lòng thử lại."
            },
            "resultCode": "00008"
        }), 500
    
    
@user_api.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    
    if data is None:
        raise ValueError("Dữ liệu JSON không hợp lệ")
    
    REQUIRED_FIELDS = {"email", "password", "name", "language", "timezone", "deviceId"}
    missing_fields = {field for field in REQUIRED_FIELDS if data.get(field) is None}
    
    if missing_fields:
        return jsonify({
            "resultMessage": {
                "en": "Please provide all required fields!",
                "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
            },
            "resultCode": "00025"
        }), 400
    
    if not validate_email(data["email"]):
        return jsonify({
            "resultMessage": {
                "en": "Please provide a valid email address!",
                "vn": "Vui lòng cung cấp một địa chỉ email hợp lệ!"
            },
            "resultCode": "00026"
        }), 400
    
    if is_email_registered(data["email"]):
        return jsonify({
            "resultMessage": {
                "en": "An account with this email address already exists.",
                "vn": "Một tài khoản với địa chỉ email này đã tồn tại."
            },
            "resultCode": "00032"
        }), 400
        
    new_user = save_new_user(data["email"], data["password"], data["name"], data["language"], data["timezone"], data["deviceId"])
    confirm_token = generate_confirm_token(new_user.id)
    # try:
    #     send_email(
    #         data["email"], 
    #         "Confirm Your Account",
    #         "confirm", 
    #         user=new_user, 
    #         token=confirm_token
    #     )
    # except Exception as e:
    #     print(e)
    #     pass
    
    return jsonify({
        "resultMessage": {
            "en": "You registered successfully.",
            "vn": "Bạn đã đăng ký thành công."
        },
        "resultCode": "00035",
        "user": "thông  tin user", # Chưa hoàn thiện -> sẽ cập nhật thêm thông tin user
        "confirmToken": confirm_token
    }), 201


