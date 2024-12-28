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
        'cooking_time' : data.get('cooking_time'),
        'description': data.get('description'),
        'content_html': data.get('content_html'),
        'foods': [
            {
                'food_name': food_name,
                'unit_name': unit_name,
                'quantity': quantity
            }
            for food_name, unit_name, quantity in zip(
                request.form.getlist('list[food_name]'),
                request.form.getlist('list[unit_name]'),
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


@recipe_api.route("/<group_id>", methods=["PUT"])
@JWT_required
@group_admin_required
@check_recipe_ownership
def update_recipe(user_id, group_id):
    '''Update recipe API'''
    data = request.form
    new_recipe = {
        'recipe_id': data.get('recipe_id'),
        'name': data.get('new_name'),
        'cooking_time': data.get('new_cooking_time'),
        'description': data.get('new_description'),
        'content_html': data.get('new_content_html'),
        'foods': [
            {
                'food_name': food_name,
                'unit_name': unit_name,
                'quantity': quantity
            }
            for food_name, unit_name, quantity in zip(
                request.form.getlist('list[new_food_name]'),
                request.form.getlist('list[new_unit_name]'),
                request.form.getlist('list[new_quantity]')
            )
        ],
        'images': [
            image for image in request.files.getlist('new_images') if image.filename
        ]
    }

    recipe_service = RecipeService()
    result = recipe_service.update_recipe(new_recipe)

    if result == "recipe not found":
        return jsonify({
            "resultMessage": {
                "en": "Recipe with ID not exist or deleted.",
                "vn": "Công thức nấu ăn không tồn tại."
        },
        "resultCode": "00195"
    }), 404
    
    return jsonify({
        "resultMessage": {
            "en": "Recipe updated successfully.",
            "vn": "Công thức đã được cập nhật thành công."
        },
        "resultCode": "00202",
        "updated_recipe": result
    }), 200


@recipe_api.route("/<group_id>", methods=["GET"])
@JWT_required
@group_member_required
def get_list_recipes(user_id, group_id):
    '''get or list of recipes'''
    recipe_service = RecipeService()

    # Lấy danh sách công thức
    recipes = recipe_service.get_list_recipes(group_id)
    return jsonify({
        "resultMessage": {
            "en": "List of recipes.",
            "vn": "Danh sách các công thức."
        },
        "resultCode": "00203",
        "recipes": recipes
    }), 200


@recipe_api.route("/<group_id>/search", methods=["GET"])
@JWT_required
@group_member_required
def search_recipe(user_id, group_id):
    '''search recipe by keyword'''
    keyword = request.json.get("keyword")
    recipe_service = RecipeService()

    # Tìm kiếm công thức
    recipes = recipe_service.search_by_keyword(group_id, keyword)
    if not recipes:
        return jsonify({
            "resultMessage": {
                "en": "No recipe found.",
                "vn": "Không tìm thấy công thức."
            },
            "resultCode": "00194"
        }), 404
    
    return jsonify({
        "resultMessage": {
            "en": "List of recipes.",
            "vn": "Danh sách các công thức."
        },
        "resultCode": "00203",
        "recipes": recipes
    }), 200
    
    
@recipe_api.route("/<group_id>/<recipe_id>", methods = ["GET"])
@JWT_required
@group_member_required
@check_recipe_ownership
def get_recipe_detail(user_id, group_id, recipe_id):
    recipe_service = RecipeService()

    # Lấy chi tiết công thức
    recipe = recipe_service.get_recipe(recipe_id)
    if not recipe:
        return jsonify({
            "resultMessage": {
                "en": "Recipe not found.",
                "vn": "Không tìm thấy công thức."
            },
            "resultCode": "00195"
        }), 404

    return jsonify({
        "resultMessage": {
            "en": "Recipe detail.",
            "vn": "Chi tiết công thức."
        },
        "resultCode": "00378",
        "detail_recipe": recipe
    }), 200

@recipe_api.route("/<group_id>", methods = ["DELETE"])
@JWT_required
@group_admin_required
@check_recipe_ownership
def delete_recipe(user_id, group_id):
    recipe_serice = RecipeService()
    recipe_id = request.json.get("recipe_id")

    result = recipe_serice.delete_recipe(recipe_id)
    
    if result == "recipe not found":
        return jsonify({
            "resultMessage": {
                "en": "Recipe with ID not exist or deleted.",
                "vn": "Công thức nấu ăn không tồn tại."
            },
            "resultCode": "00250"
        }), 404

    if result:
        return jsonify({
            "resultMessage": {
                "en": "Successfully delete recipe",
                "vn": "Xoá thành công công thức nấu ăn"
            },
            "resultCode": "00250"
        }), 200

@recipe_api.route("/<group_id>/list", methods = ["DELETE"])
@JWT_required
@group_admin_required
def delete_list_recipe(user_id, group_id):
    recipe_service = RecipeService()
    recipe_ids = request.json.get("recipe_ids")

    for recipe_id in recipe_ids:
        try:
            recipe_service.delete_recipe(recipe_id)
        except Exception as e:
            continue
    return jsonify({
        "resultMessage": {
            "en": "Successfully delete list of recipes",
            "vn": "Xoá thành công danh sách công thức nấu ăn"
        },
        "resultCode": "00250"
    }), 200