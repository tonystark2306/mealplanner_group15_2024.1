"""add status to shopping data

Revision ID: 3e6af64e3910
Revises: 15d11881b494
Create Date: 2024-12-08 18:01:57.531880

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '3e6af64e3910'
down_revision = '15d11881b494'
branch_labels = None
depends_on = None


def upgrade():
    # Tạo kiểu Enum cho shopping list
    op.execute("""
        CREATE TYPE shopping_list_status AS ENUM (
            'Draft', 
            'Active', 
            'Fully Completed', 
            'Partially Completed', 
            'Archived', 
            'Cancelled'
        );
    """)
    # Thêm cột status cho shopping list
    op.add_column('shopping_lists', sa.Column('status', sa.Enum('Draft', 'Active', 'Fully Completed', 'Partially Completed', 'Archived', 'Cancelled', name='shopping_list_status'), nullable=False))

    # Tạo kiểu Enum cho task
    op.execute("""
        CREATE TYPE task_status AS ENUM (
            'Active',
            'Completed',
            'Cancelled'
        );
    """)
    #bỏ cột status cũ
    op.drop_column('shopping_tasks', 'status')
    # Thêm cột status cho task
    op.add_column('shopping_tasks', sa.Column('status', sa.Enum('Active', 'Completed', 'Cancelled', name='task_status'), nullable=False))

def downgrade():
    op.drop_column('shopping_lists', 'status')
    op.execute("DROP TYPE shopping_list_status")
    
    op.drop_column('shopping_tasks', 'status')
    op.add_column('shopping_tasks', sa.Column('status',sa.String(length=10)), nullable=False)
    op.execute("DROP TYPE task_status")