from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
# Update this import to point to your models
from server.app.models.base import Base

# Make sure to import all your models here
from server.app.models.user import User
from server.app.models.verification_token import VerificationToken  # Add this line
from server.app.models.password_reset import PasswordReset  # Add this line
from server.app.models.login_attempt import LoginAttempt  # Add this line
from server.app.models.role import Role, UserRole  # Add this line
from server.app.models.group import Group, GroupMember  # Add this line
from server.app.models.unit import Unit  # Add this line
from server.app.models.category import Category  # Add this line
from server.app.models.food import Food
from server.app.models.meal_plan import MealPlan
from server.app.models.recipe import Recipe  # Add this line
from server.app.models.shopping import ShoppingList, ShoppingTask  # Add this line 
# from server.app.models.product import Product

config = context.config

# Thiết lập logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Cung cấp target_metadata cho Alembic để tự động tạo migrations
target_metadata = Base.metadata

def run_migrations_offline() -> None:
    """Chạy migrations ở chế độ offline."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Chạy migrations ở chế độ online."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
