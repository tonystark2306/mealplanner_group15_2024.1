"""add meal status

Revision ID: 00fd00304df6
Revises: 1ae83483db9b
Create Date: 2024-12-21 01:40:41.274929

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import text

# revision identifiers, used by Alembic.
revision = '00fd00304df6'
down_revision = '1ae83483db9b'
branch_labels = None
depends_on = None


def upgrade():
    op.execute("""
        CREATE TYPE meal_plan_status AS ENUM (
            'Scheduled', 
            'Cancelled', 
            'Completed'
        );
    """)
    # ### commands auto generated by Alembic - please adjust! ###
    # Migration script
    op.add_column('meal_plans', sa.Column('status', sa.Enum('Scheduled', 'Cancelled', 'Completed', name='meal_plan_status'), nullable=True))
    # Sau khi thêm cột `status`, thêm giá trị mặc định cho tất cả các bản ghi
    conn = op.get_bind()
    conn.execute(text("UPDATE meal_plans SET status = 'Scheduled' WHERE status IS NULL"))
    # Thay đổi lại cột `status` để `NOT NULL`
    op.alter_column('meal_plans', 'status', nullable=False)

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('meal_plans', 'status')
    op.execute("DROP TYPE meal_plan_status")
    # ### end Alembic commands ###