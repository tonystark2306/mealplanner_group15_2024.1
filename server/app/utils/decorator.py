from functools import wraps
import jwt
from flask import request, jsonify
from config import secret_key


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
        
        return f(user_id, *args, **kwargs)

    return decorated_function