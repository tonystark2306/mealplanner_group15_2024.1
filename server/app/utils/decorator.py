from functools import wraps
from inspect import signature
import logging
import jwt

from flask import request, jsonify

from config import secret_key
from .. import db
from ..models.user import User
from ..services.user.group_service import GroupService


def JWT_required(f):
    """Decorator to require JSON Web Token for API access."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({
                "resultMessage": {
                    "en": "Access denied. No token provided.",
                    "vn": "Truy cập bị từ chối. Không có token được cung cấp."
                },
                "resultCode": "00006"
            }), 401
        
        auth_header_parts = auth_header.split(" ")
        if len(auth_header_parts) != 2 or not auth_header_parts[1]:
            return jsonify({
                "resultMessage": {
                    "en": "Access denied. No token provided.",
                    "vn": "Truy cập bị từ chối. Không có token được cung cấp."
                },
                "resultCode": "00006"
            }), 401
            
        token = auth_header_parts[1]
        try:
            payload = jwt.decode(token, secret_key, algorithms=["HS256"])
        except jwt.ExpiredSignatureError:
            return jsonify({
                "resultMessage": {
                    "en": "Invalid token.",
                    "vn": "Token không hợp lệ. Token có thể đã hết hạn."
                },
                "resultCode": "00012"
            }), 401
        except jwt.InvalidTokenError:
            return jsonify({
                "resultMessage": {
                    "en": "Invalid token.",
                    "vn": "Token không hợp lệ. Token có thể đã hết hạn."
                },
                "resultCode": "00012"
            }), 401
            
        user_id = payload.get("user_id")
        if not user_id:
            return jsonify({
                "resultMessage": {
                    "en": "Invalid token.",
                    "vn": "Token không hợp lệ. Token có thể đã hết hạn."
                },
                "resultCode": "00012"
            }), 401
            
        try:
            user = db.session.execute(
                db.select(User).where(User.id == user_id)
            ).scalar()
        except Exception as e:
            logging.error(f"Internal server error: {str(e)}")
            return jsonify({
                "resultMessage": {
                    "en": "An internal server error has occurred, please try again.",
                    "vn": "Đã xảy ra lỗi máy chủ nội bộ, vui lòng thử lại."
                },
                "resultCode": "00008"
            }), 500
            
        if not user:
            return jsonify({
                "resultMessage": {
                    "en": "Invalid token.",
                    "vn": "Token không hợp lệ. Token có thể đã hết hạn."
                },
                "resultCode": "00012"
            }), 401
            
        func_signature = signature(f)
        if "user_id" in func_signature.parameters:
            return f(user_id, *args, **kwargs)
        elif "user" in func_signature.parameters:
            return f(user, *args, **kwargs)
        
        return f(*args, **kwargs)

    return decorated_function

def group_member_required(f):
    @wraps(f)
    def decorated_function(user_id, group_id, *args, **kwargs):
        group_service = GroupService()
        group = group_service.get_group_by_id(group_id)
        if not group:
            return jsonify({
                "resultMessage": {
                    "en": "Group not found.",
                    "vn": "Không tìm thấy nhóm."
                },
                "resultCode": "00030"
            }), 404
            
        is_member = group_service.is_member_of_group(user_id, group_id)
        if not is_member:
            return jsonify({
                "resultMessage": {
                    "en": "You are not a member of this group.",
                    "vn": "Bạn không phải là thành viên của nhóm này."
                },
                "resultCode": "00031"
            }), 403
            
        return f(user_id, group_id, *args, **kwargs)
    return decorated_function