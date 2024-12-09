from functools import wraps
from inspect import signature
import jwt

from flask import request, jsonify

from config import secret_key
from ..services.user.group_service import GroupService
from ..repository.user_repository import UserRepository
from ..repository.role_repository import RoleRepository


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
            
        user_repository = UserRepository()
        user = user_repository.get_user_by_id(user_id)
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
    '''Decorator to require user to be a member of a group to access the API'''
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


def group_admin_required(f):
    '''Decorator to require user to be an admin of a group to access the API'''
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
            
        if user_id != group.admin_id:
            return jsonify({
                "resultMessage": {
                    "en": "You are not an admin of this group.",
                    "vn": "Bạn không phải là admin của nhóm này."
                },
                "resultCode": "00032"
            }), 403
        
        return f(user_id, group_id, *args, **kwargs)
    
    return decorated_function


def system_admin_required(f):
    '''Decorator to require user to be a system admin to access the API'''
    @wraps(f)
    def decorated_function(user_id, *args, **kwargs):
        role_repository = RoleRepository()
        role = role_repository.get_role_of_user(user_id)
        if role != "admin":
            return jsonify({
                "resultMessage": {
                    "en": "You need to have system admin rights to access this API.",
                    "vn": "Bạn cần có quyền admin hệ thống để truy cập vào API này."
                },
                "resultCode": "00033"
            }), 403
        
        return f(user_id, *args, **kwargs)
    
    return decorated_function


def validate_fields(allow_fields):
    """Decorator to validate fields in request JSON data."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Lấy dữ liệu từ request
            data = request.get_json() or {}

            # Kiểm tra các trường bắt buộc có giá trị hay không
            missing_fields = {field for field in allow_fields if not data.get(field)}
            if missing_fields:
                return jsonify({
                    "resultMessage": {
                        "en": "Please provide all required fields!",
                        "vn": "Vui lòng cung đầy đủ các trường bắt buộc!"
                    },
                    "resultCode": "00099"
                }), 400

            # Nếu tất cả hợp lệ, gọi hàm gốc
            return func(*args, **kwargs)
        return wrapper
    return decorator