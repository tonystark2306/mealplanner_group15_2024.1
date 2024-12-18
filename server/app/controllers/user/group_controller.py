from flask import request, jsonify
from flasgger.utils import swag_from

from . import user_api
from ...services.user.group_service import GroupService
from ...utils.decorator import JWT_required, group_member_required, group_admin_required


@user_api.route("/group", methods=["GET"])
@JWT_required
@swag_from(
    "../../docs/user/group/get_all_groups.yaml", 
    endpoint="user_api.get_all_groups", 
    methods=["GET"]
)
def get_all_groups(user_id):
    group_service = GroupService()
    groups = group_service.list_groups_of_user(user_id)
    return jsonify({
        "resultMessage": {
            "en": "Fetching user's groups successfully!",
            "vn": "Lấy danh sách nhóm của user thành công!"
        },
        "groups": groups,
        "resultCode": "00094"
    }), 200


@user_api.route("/group/<group_id>", methods=["GET"])
@JWT_required
@group_member_required
@swag_from(
    "../../docs/user/group/get_group_members.yaml", 
    endpoint="user_api.get_group_members", 
    methods=["GET"]
)
def get_group_members(user_id, group_id):
    group_service = GroupService()
    group = group_service.get_group_by_id(group_id)
    if not group:
        return jsonify({
            "resultMessage": {
                "en": "Group not found.",
                "vn": "Không tìm thấy nhóm."
            },
            "resultCode": "00097"
        }), 404
    
    if not group_service.is_member_of_group(user_id, group_id):
        return jsonify({
            "resultMessage": {
                "en": "You are not a member of this group.",
                "vn": "Bạn không phải là thành viên của nhóm này."
            },
            "resultCode": "00097"
        }), 403
        
    group_members = group_service.list_members_of_group(group_id)
    return jsonify({
        "resultMessage": {
            "en": "Successfully",
            "vn": "Thành công"
        },
        "groupAdmin": group.admin_id,
        "members": group_members,
        "resultCode": "00098"
    }), 200


@user_api.route("/group", methods=["POST"])
@JWT_required
@swag_from(
    "../../docs/user/group/create_group.yaml", 
    endpoint="user_api.create_group", 
    methods=["POST"]
)
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
    for username in member_usernames:
        user_to_add = group_service.get_user_by_username(username)
        if not user_to_add:
            return jsonify({
                "resultMessage": {
                    "en": f"User {username} does not exist.",
                    "vn": f"Không tồn tại user {username}."
                },
                "resultCode": "00099x"
            }), 404
        
        if user_to_add.id == user_id:
            return jsonify({
                "resultMessage": {
                    "en": "You cannot add yourself to the group.",
                    "vn": "Bạn không thể thêm chính mình vào nhóm."
                },
                "resultCode": "00094"
            }), 400
            
    new_group = group_service.save_new_group(user_id, group_name, member_usernames)
    return jsonify({
        "resultMessage": {
            "en": "Your group has been created successfully",
            "vn": "Tạo nhóm thành công"
        },
        "resultCode": "00095",
        "group": new_group.to_json()
    }), 201


@user_api.route("/group/<group_id>/add", methods=["POST"])
@JWT_required
@group_member_required
@swag_from(
    "../../docs/user/group/add_members.yaml", 
    endpoint="user_api.add_members", 
    methods=["POST"]
)
def add_members(user_id, group_id):
    data = request.get_json()
    if not data:
        return jsonify({
            "resultMessage": {
                "en": "Invalid JSON data.",
                "vn": "Dữ liệu JSON không hợp lệ."
            },
            "resultCode": "00004"
        }), 400
    
    member_usernames = data.get("memberUsernames")
    if not member_usernames:
        return jsonify({
            "resultMessage": {
                "en": "Please provide all required fields!",
                "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
            },
            "resultCode": "00025"
        }), 400
    
    group_service = GroupService()
    for username in member_usernames:
        user_to_add = group_service.get_user_by_username(username)
        if not user_to_add:
            return jsonify({
                "resultMessage": {
                    "en": f"User {username} does not exist.",
                    "vn": f"Không tồn tại user {username}."
                },
                "resultCode": "00099x"
            }), 404
            
        if group_service.is_member_of_group(user_to_add.id, group_id):
            return jsonify({
                "resultMessage": {
                    "en": f"User {username} is already a member of this group.",
                    "vn": f"User {username} đã là thành viên của nhóm này."
                },
                "resultCode": "00101"
            }), 400
    
    group_service.add_members_to_group(group_id, member_usernames)
    return jsonify({
        "resultMessage": {
            "en": "Users added to the group successfully",
            "vn": "Thêm người dùng vào nhóm thành công"
        },
        "resultCode": "00102"
    }), 200
    
    
@user_api.route("/group/<group_id>", methods=["DELETE"])
@JWT_required
@group_admin_required
@swag_from(
    "../../docs/user/group/delete_member.yaml", 
    endpoint="user_api.delete_member", 
    methods=["DELETE"]
)
def delete_member(user_id, group_id):
    data = request.get_json()
    if not data:
        return jsonify({
            "resultMessage": {
                "en": "Invalid JSON data.",
                "vn": "Dữ liệu JSON không hợp lệ."
            },
            "resultCode": "00004"
        }), 400
    
    username = data.get("username")
    if not username:
        return jsonify({
            "resultMessage": {
                "en": "Please provide all required fields!",
                "vn": "Vui lòng cung cấp tất cả các trường bắt buộc!"
            },
            "resultCode": "00025"
        }), 400
    
    group_service = GroupService()
    user_to_remove = group_service.get_user_by_username(username)
    if not user_to_remove:
        return jsonify({
            "resultMessage": {
                "en": f"User {username} does not exist.",
                "vn": f"Không tồn tại user {username}."
                },
                "resultCode": "00099x"
            }), 404
        
    if not group_service.is_member_of_group(user_to_remove.id, group_id):
        return jsonify({
            "resultMessage": {
                "en": f"User {username} is not a member of this group.",
                "vn": f"User {username} không phải là thành viên của nhóm này."
            },
            "resultCode": "00099"
        }), 400
    
    group_service.remove_member_from_group(user_to_remove.id, group_id)
    return jsonify({
        "resultMessage": {
            "en": "User removed from the group successfully",
            "vn": "Xóa thành công"
        },
        "resultCode": "00106"
    }), 200
