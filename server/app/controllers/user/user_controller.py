from flask import jsonify

from . import user_api
from ...services.user.user_service import UserService
from ...utils.decorator import JWT_required


@user_api.route("/", methods=["GET"])
@JWT_required
def get_user(user):
    return jsonify({
        "resultMessage": {
            "en": "The user information has gotten successfully.",
            "vn": "Thông tin người dùng đã được lấy thành công."
        },
        "resultCode": "00089",
        "user": user.to_json()
    })
    
    
@user_api.route("/", methods=["DELETE"])
@JWT_required
def delete_user(user):
    user_service = UserService()
    user_service.delete_user_from_db(user)
    return jsonify({
        "resultMessage": {
            "en": "Your account has been deleted successfully.",
            "vn": "Tài khoản của bạn đã bị xóa thành công."
        },
        "resultCode": "00092"
    }), 200