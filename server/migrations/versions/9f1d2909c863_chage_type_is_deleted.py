"""chage type is_deleted

Revision ID: 9f1d2909c863
Revises: b045f9a2f89c
Create Date: 2024-12-13 02:10:22.442792

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '9f1d2909c863'
down_revision = 'b045f9a2f89c'
branch_labels = None
depends_on = None


def upgrade():
    # Chuyển đổi kiểu dữ liệu của `is_deleted` trong `recipe_images`
    op.execute("""
        ALTER TABLE recipe_images
        ALTER COLUMN is_deleted TYPE BOOLEAN
        USING is_deleted::BOOLEAN;
    """)

    # Chuyển đổi kiểu dữ liệu của `is_deleted` trong `recipes`
    op.execute("""
        ALTER TABLE recipes
        ALTER COLUMN is_deleted TYPE BOOLEAN
        USING is_deleted::BOOLEAN;
    """)



def downgrade():
    # Chuyển đổi kiểu dữ liệu của `is_deleted` trong `recipes` trở lại `INTEGER`
    op.execute("""
        ALTER TABLE recipes
        ALTER COLUMN is_deleted TYPE INTEGER
        USING CASE 
            WHEN is_deleted = TRUE THEN 1
            ELSE 0
        END;
    """)

    # Chuyển đổi kiểu dữ liệu của `is_deleted` trong `recipe_images` trở lại `INTEGER`
    op.execute("""
        ALTER TABLE recipe_images
        ALTER COLUMN is_deleted TYPE INTEGER
        USING CASE 
            WHEN is_deleted = TRUE THEN 1
            ELSE 0
        END;
    """)

