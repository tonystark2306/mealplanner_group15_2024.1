from werkzeug.exceptions import HTTPException
from flask import jsonify


def handle_exception(e):
    if isinstance(e, HTTPException):
        response = e.get_response()
        response.data = jsonify({"error": str(e)}).data
        response.content_type = "application/json"
        return response

    return jsonify({
        "resultMessage": {
            "en": "An internal server error has occurred, please try again.",
            "vn": "Đã xảy ra lỗi máy chủ nội bộ, vui lòng thử lại."
        },
        "resultCode": "00008",
        "error": str(e)
    }), 500