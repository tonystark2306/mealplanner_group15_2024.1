"""Add new field 'is_active' to table 'users'

Revision ID: cdff69d3aa41
Revises: ec26c0e59aa0
Create Date: 2024-12-28 18:16:05.064734

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'cdff69d3aa41'
down_revision = 'ec26c0e59aa0'
branch_labels = None
depends_on = None


def upgrade():
    # Step 1: Add the column as nullable
    with op.batch_alter_table('users', schema=None) as batch_op:
        batch_op.add_column(sa.Column('is_active', sa.Boolean(), nullable=True))

        # Step 2: Populate the column with default value
    op.execute("UPDATE users SET is_active = FALSE WHERE is_active IS NULL")

    # Step 3: Alter the column to set nullable=False
    with op.batch_alter_table('users', schema=None) as batch_op:
        batch_op.alter_column('is_active', nullable=False)

def downgrade():
    # Revert changes: Drop the column
    with op.batch_alter_table('users', schema=None) as batch_op:
        batch_op.drop_column('is_active')