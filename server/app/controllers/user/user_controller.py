import logging

from flask import request, jsonify

from . import user_api
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