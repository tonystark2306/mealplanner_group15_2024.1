# Các api chính
# Create group
# Add member
# Delete member
# Get group members
# Get user
# Delete user
#tất cả đều yêu cầu user phải đăng nhập

#import
from flask import request, jsonify
from server.app.services.user.group_service import create_group
from . import user_api
from flask_jwt_extended import jwt_required, get_jwt_identity, verify_jwt_in_request

@user_api.route("/group", methods=["POST"])
@jwt_required()  # Remove fresh=True to accept any valid JWT token
def create_group_handler():  # Changed function name from hehehe to create_group_handler
    try:
        # Verify token first
        verify_jwt_in_request()
        user_id = get_jwt_identity()
        
        if not user_id:
            return jsonify({
                "resultMessage": {
                    "en": "Invalid or expired token",
                    "vn": "Token không hợp lệ hoặc đã hết hạn"
                },
                "resultCode": "00401"
            }), 401

        # Get group_name from request JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                "resultMessage": {
                    "en": "No data provided",
                    "vn": "Không có dữ liệu được cung cấp"
                },
                "resultCode": "00025"
            }), 400
            
        group_name = data.get('group_name')  # Get actual group name from request
        if not group_name:
            return jsonify({
                "resultMessage": {
                    "en": "Group name is required!",
                    "vn": "Tên nhóm là bắt buộc!"
                },
                "resultCode": "00025"
            }), 400

        # Tạo nhóm mới
        group = create_group(user_id, group_name)

        return jsonify({
            "resultMessage": {
                "en": "Create group successfully!",
                "vn": "Tạo nhóm thành công!"
            },
            "resultCode": "00000",
            "group": group.to_json()  # Giả sử phương thức to_json() trả về thông tin nhóm
        }), 200
    
    except Exception as e:
        print(e)
        return jsonify({
            "resultMessage": {
                "en": "An internal server error has occurred, please try again.",
                "vn": "Đã xảy ra lỗi máy chủ nội bộ, vui lòng thử lại."
        }, "resultCode": "00008"
        }), 500

