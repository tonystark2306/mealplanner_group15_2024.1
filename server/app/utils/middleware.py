from functools import wraps
from flask import jsonify, request
from ..models.shopping import ShoppingList
from ..models.fridge_item import FridgeItem
from ..models.shopping import ShoppingTask
from ..models.recipe import Recipe

from .. import db




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


def check_item_ownership(f):
    '''Decorator to check if the user has access to the fridge item'''
    @wraps(f)
    def decorated_function(*args, **kwargs):
        group_id = kwargs.get('group_id') or request.view_args.get('group_id')
        data = request.json
        item_id = data.get("itemId") or kwargs.get('item_id')

        # Kiểm tra nếu thiếu thông tin cần thiết
        if not item_id:
            return jsonify({
                "resultMessage": {
                    "en": "Missing itemId in the request.",
                    "vn": "Thiếu itemId trong yêu cầu."
                },
                "resultCode": "00234"
            }), 400

        # Truy vấn để kiểm tra quyền sở hữu
        fridge_item = db.session.query(FridgeItem).filter_by(id=item_id, owner_id=group_id).first()

        if not fridge_item:
            return jsonify({
                "resultMessage": {
                    "en": "You do not have access to this fridge item.",
                    "vn": "Bạn không có quyền truy cập mục này trong tủ lạnh."
                },
                "resultCode": "00235"
            }), 403

        return f(*args, **kwargs)
    return decorated_function


from functools import wraps
from flask import jsonify, request

def check_list_ownership(f):
    ''''Decorator to check if user has access to the shopping list'''
    @wraps(f)
    def decorated_function(*args, **kwargs):
        group_id = kwargs.get('group_id') or request.view_args.get('group_id')
        data = request.json
        list_id = data.get("list_id") or kwargs.get('list_id')  # Lấy list_id từ request hoặc URL

        # Kiểm tra nếu thiếu list_id trong yêu cầu
        if not list_id:
            return jsonify({
                "resultMessage": {
                    "en": "Missing list_id in the request.",
                    "vn": "Thiếu list_id trong yêu cầu."
                },
                "resultCode": "00247"
            }), 400

        # Truy vấn để kiểm tra quyền sở hữu
        shopping_list = db.session.query(ShoppingList).filter_by(id=list_id, group_id=group_id).first()

        # Nếu shopping_list không tồn tại hoặc không thuộc group
        if not shopping_list:
            return jsonify({
                "resultMessage": {
                    "en": "Shopping list does not belong to this group.",
                    "vn": "Danh sách mua sắm không thuộc nhóm này."
                },
                "resultCode": "00248"
            }), 403

        return f(*args, **kwargs)
    return decorated_function


def check_task_ownership(f):
    '''Decorator to check if the task belongs to the group'''
    @wraps(f)
    def decorated_function(*args, **kwargs):
        group_id = kwargs.get('group_id')  # Lấy group_id từ URL
        data = request.json
        task_id = data.get("task_id")  

        # Kiểm tra nếu thiếu task_id trong yêu cầu
        if not task_id:
            return jsonify({
                "resultMessage": {
                    "en": "Missing task_id in the request.",
                    "vn": "Thiếu task_id trong yêu cầu."
                },
                "resultCode": "00292"
            }), 400

        # Truy vấn để kiểm tra quyền sở hữu
        task = db.session.query(ShoppingTask).join(ShoppingList).filter(
            ShoppingTask.id == task_id,
            ShoppingList.group_id == group_id
        ).first()

        # Nếu task không tồn tại hoặc không thuộc nhóm
        if not task:
            return jsonify({
                "resultMessage": {
                    "en": "Task does not belong to this group.",
                    "vn": "Nhiệm vụ không thuộc nhóm này."
                },
                "resultCode": "00293"
            }), 403

        return f(*args, **kwargs)
    return decorated_function


def check_recipe_ownership(f):
    '''Decorator to check if the recipe belongs to the group'''
    @wraps(f)
    def decorated_function(*args, **kwargs):
        group_id = kwargs.get('group_id') or request.view_args.get('group_id')
        data = request.json
        recipe_id = data.get("recipe_id") or kwargs.get('recipe_id')  # Lấy list_id từ request hoặc URL

        # Kiểm tra nếu thiếu recipe_id trong yêu cầu
        if not recipe_id:
            return jsonify({
                "resultMessage": {
                    "en": "Missing recipe_id in the request.",
                    "vn": "Thiếu recipe_id trong yêu cầu."
                },
                "resultCode": "00298"
            }), 400

        # Truy vấn để kiểm tra quyền sở hữu
        recipe = db.session.query(Recipe).filter_by(id=recipe_id, group_id=group_id).first()

        # Nếu recipe không tồn tại hoặc không thuộc nhóm
        if not recipe:
            return jsonify({
                "resultMessage": {
                    "en": "Recipe does not belong to this group.",
                    "vn": "Công thức không thuộc nhóm này."
                },
                "resultCode": "00299"
            }), 403

        return f(*args, **kwargs)
    return decorated_function
