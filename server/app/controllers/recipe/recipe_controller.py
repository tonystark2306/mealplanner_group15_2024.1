from flask import request, jsonify

from . import recipe_api

from ...utils.decorator import JWT_required, group_member_required, group_admin_required
from ...utils.middleware import validate_fields, check_recipe_ownership
from ...services.recipe.recipe_service import RecipeService



@recipe_api.route("/<group_id>", methods=["POST"])
@JWT_required
@group_admin_required
def create_recipe(user_id, group_id):
    '''Create recipe API'''
    data = request.form
    recipe = {
        'group_id': group_id,
        'name': data.get('name'),
        'description': data.get('description'),
        'content_html': data.get('content_html'),
        'foods': [
            {
                'food_name': food_name,
                'quantity': quantity
            }
            for food_name, quantity in zip(
                request.form.getlist('list[food_name]'),
                request.form.getlist('list[quantity]')
            )
        ],
        'images': [
            image for image in request.files.getlist('images') if image.filename
        ]
    }

    recipe_service = RecipeService()
    result = recipe_service.create_recipe(recipe)

    if result == "food not found":
        return jsonify({
            "resultMessage": {
                "en": "Food item with provided name does not exist.",
                "vn": "Không tìm thấy một món ăn với tên cung cấp trong mảng."
            },
            "resultCode": "00194"
        }), 404
    
    return jsonify({
        "resultMessage": {
            "en": "Recipe created successfully.",
            "vn": "Công thức đã được tạo thành công."
        },
        "resultCode": "00202",
        "created_recipe": result
    }), 201


