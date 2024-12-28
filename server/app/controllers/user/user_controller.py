from flask import jsonify
from flasgger.utils import swag_from

from . import user_api
from ...services.user.user_service import UserService
from ...utils.decorator import JWT_required


@user_api.route("/", methods=["GET"])
@JWT_required
@swag_from("../../docs/user/get_user.yaml", endpoint="user_api.get_user", methods=["GET"])
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
@swag_from("../../docs/user/delete_user.yaml", endpoint="user_api.delete_user", methods=["DELETE"])
def delete_user(user):
    user_service = UserService()
    user_service.delete_user_account(user)
    return jsonify({
        "resultMessage": {
            "en": "The user account has been deleted successfully.",
            "vn": "Tài khoản người dùng đã được xóa thành công."
        },
        "resultCode": "00092"
    }), 200