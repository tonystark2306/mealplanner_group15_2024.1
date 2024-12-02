import logging

from flask import request, jsonify
from validate_email_address import validate_email

from . import user_api
from ...services.user.auth_service import (
    validate_login, generate_access_token, generate_refresh_token, check_email_registered,
    save_new_user, generate_verification_code, generate_confirm_token, invalidate_token,
    verify_refresh_token, verify_verification_code, verify_user_email, is_verified, validate_password
)
from ...email import send_email
from ...utils.decorator import JWT_required


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
        
        
@user_api.route("/refresh-token", methods=["POST"])
def refresh_token():
    try:
        data = request.get_json()
        if data is None:
            raise ValueError("Dữ liệu JSON không hợp lệ.")
        
        refresh_token = data.get("refresh_token")
        
        if refresh_token is None:
            return jsonify({
                "resultMessage": {
                    "en": "Please provide all required fields!",
                    "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
                },
                "resultCode": "00025"
            }), 400
        
        user_id = verify_refresh_token(refresh_token)
        
        if user_id is None:
            return jsonify({
                "resultMessage": {
                    "en": "Invalid token. Token may have expired.",
                    "vn": "Token không hợp lệ. Token có thể đã hết hạn."
                },
                "resultCode": "00012"
            }), 400
            
        new_access_token = generate_access_token(user_id)
        new_refresh_token = generate_refresh_token(user_id)

        return jsonify({
            "resultMessage": {
                "en": "Token refreshed successfully.",
                "vn": "Token đã được làm mới thành công."
            },
            "resultCode": "00065",
            "access_token": new_access_token,
            "refresh_token": new_refresh_token
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
        
        
@user_api.route("/logout", methods=["POST"])
@JWT_required
def logout(user_id):
    try:
        if invalidate_token(user_id):
            return "", 204
        
        return jsonify({
            "resultMessage": {
                "en": "Invalid token.",
                "vn": "Token không hợp lệ. Token có thể đã hết hạn."
            },
            "resultCode": "00012"
        }), 401

    except Exception as e:
        logging.error(f"Internal server error: {str(e)}")
        return jsonify({
            "resultMessage": {
                "en": "An internal server error has occurred, please try again.",
                "vn": "Đã xảy ra lỗi máy chủ nội bộ, vui lòng thử lại."
            },
            "resultCode": "00008"
        }), 500
        
        
@user_api.route("/register", methods=["POST"])
def register():
    try:
        data = request.get_json()
        if data is None:
            raise ValueError("Dữ liệu JSON không hợp lệ.")
        
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
        
        existed_user = check_email_registered(data["email"])
        if existed_user:
            return jsonify({
                "resultMessage": {
                    "en": "An account with this email address already exists.",
                    "vn": "Một tài khoản với địa chỉ email này đã tồn tại."
                },
                "resultCode": "00032"
            }), 400
            
        if not validate_password(data["password"]):
            return jsonify({
                "resultMessage": {
                    "en": "Your password should be between 6 and 20 characters long.",
                    "vn": "Vui lòng cung cấp một mật khẩu dài hơn 6 và ngắn hơn 20 ký tự."
                },
                "resultCode": "00066"
            }), 400
            
        new_user = save_new_user(data["email"], data["password"], data["name"], data["language"], data["timezone"], data["deviceId"])
        verification_code = generate_verification_code(new_user.email)
        confirm_token = generate_confirm_token(new_user.email)
        send_email(
            to=data["email"], 
            subject="Your Verification Code from Meal Planner",
            template="confirm",
            user=new_user,
            code=verification_code
        )
        
        return jsonify({
            "resultMessage": {
                "en": "You registered successfully.",
                "vn": "Bạn đã đăng ký thành công."
            },
            "resultCode": "00035",
            "user": new_user.to_json(),
            "confirmToken": confirm_token
        }), 201
        
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
        
        
@user_api.route("/send-verification-code", methods=["POST"])
def send_verification_code():
    try:
        data = request.get_json()
        if data is None:
            raise ValueError("Dữ liệu JSON không hợp lệ.")
        
        email = data.get("email")

        if not email:
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

        registered_user = check_email_registered(email)
        if not registered_user:
            return jsonify({
                "resultMessage": {
                    "en": "Your email has not been activated, please register first.",
                    "vn": "Email của bạn chưa được kích hoạt, vui lòng đăng ký trước."
                },
                "resultCode": "00043"
            }), 400
            
        if is_verified(email):
            return jsonify({
                "resultMessage": {
                    "en": "Your email has already been verified.",
                    "vn": "Email của bạn đã được xác minh."
                },
                "resultCode": "00046"
            }), 400

        verification_code = generate_verification_code(email)
        confirm_token = generate_confirm_token(email)
        send_email(
            to=data["email"], 
            subject="Your Verification Code from Meal Planner",
            template="confirm",
            user=registered_user,
            code=verification_code
        )

        return jsonify({
            "resultMessage": {
                "en": "Code has been sent to your email successfully.",
                "vn": "Mã đã được gửi đến email của bạn thành công."
            },
            "resultCode": "00048",
            "confirmToken": confirm_token
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
        
        
@user_api.route("/verify-email", methods=["POST"])
def verify_email():
    try:
        data = request.get_json()
        if data is None:
            raise ValueError("Dữ liệu JSON không hợp lệ.")
        
        confirm_token = data.get("confirm_token")
        verification_code = data.get("verification_code")

        if not confirm_token or not verification_code:
            return jsonify({
                "resultMessage": {
                    "en": "Please provide all required fields!",
                    "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
                },
                "resultCode": "00025"
            }), 400
        
        user = verify_verification_code(confirm_token, verification_code)
        if user and verify_user_email(user.email):
            access_token = generate_access_token(user.id)
            refresh_token = generate_refresh_token(user.id)
            return jsonify({
                "resultMessage": {
                    "en": "Your email address has been verified successfully.",
                    "vn": "Địa chỉ email của bạn đã được xác minh thành công."
                },
                "resultCode": "00058",
                "access_token": access_token,
                "refresh_token": refresh_token
            }), 200
        else:
            return jsonify({
                "resultMessage": {
                    "en": "The code you entered does not match the code we sent to your email. Please check again.",
                    "vn": "Mã bạn nhập không khớp với mã chúng tôi đã gửi đến email của bạn. Vui lòng kiểm tra lại."
                },
                "resultCode": "00054"
            }), 400
            
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