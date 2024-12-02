from flask import request, jsonify

from . import user_api
from ...services.user.group_service import GroupService
from ...utils.decorator import JWT_required


@user_api.route("/group", methods=["POST"])
@JWT_required
def create_group(user_id):
    data = request.get_json()
    if not data:
        return jsonify({
            "resultMessage": {
                "en": "Invalid JSON data.",
                "vn": "Dữ liệu JSON không hợp lệ."
            },
            "resultCode": "00004"
        }), 400
    
    group_name = data.get("group_name")
    if not group_name:
        return jsonify({
            "resultMessage": {
                "en": "Please provide all required fields!",
                "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
            },
            "resultCode": "00025"
        }), 400
        
    member_usernames = data.get("memberUsernames")
    group_service = GroupService()
    new_group = group_service.save_new_group(user_id, group_name, member_usernames)
    return jsonify({
        "resultMessage": {
            "en": "Your group has been created successfully",
            "vn": "Tạo nhóm thành công"
        },
        "resultCode": "00095",
        "group": new_group.to_json()
    }), 201
