import json
from sqlalchemy.orm import joinedload
from app import create_app, db
from app.models.user import User
from app.models.role import Role, UserRole


def load_admin_accounts_from_json():
    with open("data_initialization/admin_accounts.json", "r", encoding="utf-8") as file:
        data = json.load(file)
    return data

admin_accounts = load_admin_accounts_from_json()

def generate_admin_accounts_data():
    data = []
    for account in admin_accounts:
        admin_account = User(
            email=account["email"],
            password=account["password"],
            username=account["username"],
            name=account["name"],
            language=account["language"],
            timezone=account["timezone"],
            device_id=account["device_id"],
            is_verified=account["is_verified"]
        )
        admin_account.avatar_url = "https://cdn-icons-png.flaticon.com/512/2942/2942813.png"
        data.append(admin_account)

    return data


def initialize_data():
    app = create_app()
    with app.app_context():
        existed_admin_role = db.session.execute(
            db.select(Role).where(Role.role_name == "admin")
        ).scalar()
        
        if not existed_admin_role:
            admin_role = Role(role_name="admin")
            db.session.add(admin_role)
            db.session.commit()
            print("Admin role has been initialized.")
        else:
            admin_role = existed_admin_role
            print("Admin role already exists in the database.")
            
        existed_admin = db.session.execute(
            db.select(User)
            .join(UserRole, User.id == UserRole.user_id)
            .join(Role, UserRole.role_id == Role.id)
            .where(Role.role_name == "admin")
            .options(joinedload(User.user_roles))
            .limit(1)
        ).scalars().first()
        
        if not existed_admin:
            admin_accounts_data = generate_admin_accounts_data()
            db.session.bulk_save_objects(admin_accounts_data)
            db.session.commit()
            
            for account in admin_accounts_data:
                admin = db.session.execute(
                    db.select(User).where(User.email == account.email)
                ).scalar()
                
                user_role = UserRole(user_id=admin.id, role_id=admin_role.id)
                db.session.add(user_role)
            
            db.session.commit()
            print(f"{len(admin_accounts_data)} admin accounts have been initialized.")
        else:
            print("Admin accounts already exist in the database.")