from flask import request, jsonify
from ...services.user.group_service import GroupService
from . import user_api
from ...utils.decorator import JWT_required

group_service = GroupService()

@user_api.route("/group", methods=["POST"])
@JWT_required
def create_group_handler(user_id):
    try:
        # Verify token first
        if not user_id:
            return jsonify({
                "resultMessage": {
                    "en": "Invalid or expired token",
                    "vn": "Token không hợp lệ hoặc đã hết hạn"
                },
                "resultCode": "00401"
            }), 401

        # Get group_name and avatar from request
        data = request.form  # Get the form data (multipart/form-data)

        if not data:
            return jsonify({
                "resultMessage": {
                    "en": "No data provided",
                    "vn": "Không có dữ liệu được cung cấp"
                },
                "resultCode": "00025"
            }), 400

        group_name = data.get('group_name')
        avatar = request.files.get('avatar')  # Get avatar file from the request

        if not group_name:
            return jsonify({
                "resultMessage": {
                    "en": "Group name is required!",
                    "vn": "Tên nhóm là bắt buộc!"
                },
                "resultCode": "00025"
            }), 400



        # Create the group with the avatar URL
        group = group_service.create_group(user_id, group_name, avatar)
        
        if group is None:
            return jsonify({
                "resultMessage": {
                    "en": "Failed to create group",
                    "vn": "Không thể tạo nhóm"
                },
                "resultCode": "00026"
            }), 400

        return jsonify({
            "resultMessage": {
                "en": "Create group successfully!",
                "vn": "Tạo nhóm thành công!"
            },
            "resultCode": "00000",
            "group": {
                "id": group.id,
                "group_name": group.group_name,
                "avatar_url": group.group_avatar
            }
        }), 200

    except Exception as e:
        print(e)
        return jsonify({
            "resultMessage": {
                "en": "An internal server error has occurred, please try again.",
                "vn": "Đã xảy ra lỗi máy chủ nội bộ, vui lòng thử lại."
            },
            "resultCode": "00008"
        }), 500
