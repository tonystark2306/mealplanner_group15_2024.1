from app.models.group import Group
from app import db
from ...utils.firebase_helper import FirebaseHelper
from werkzeug.utils import secure_filename
from app.repository.group_repository import GroupRepository


class GroupService:
    def __init__(self):
        self.firebase_helper = FirebaseHelper()
        self.group_repository = GroupRepository()
    
    #Tạo nhóm mới. đẩy avatar lên firebase
    def create_group(self, user_id, group_name, group_avatar):
        avatar_url = ""
        if group_avatar: #call firebase helper to upload image
            filename = secure_filename(group_avatar.filename)
            avatar_url = self.firebase_helper.upload_image(group_avatar, f'group/{filename}')

        group = self.group_repository.add_group(user_id, group_name, avatar_url)
        if group:
            return group
        return None
