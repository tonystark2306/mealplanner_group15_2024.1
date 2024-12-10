



"""add status to shopping data

Revision ID: phong_da_tu1
Revises: 131bb5450bfd
Create Date: 2024-12-11 01:01:57.531880

"""







from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'phong_da_tu1'
down_revision = '131bb5450bfd'
branch_labels = None
depends_on = None

def upgrade():
    # Update the enum type
    op.execute("ALTER TYPE shopping_list_status ADD VALUE 'Deleted'")
    op.execute("ALTER TYPE task_status ADD VALUE 'Deleted'")
def downgrade():
    # Note: Downgrading an enum type is more complex and may require a custom approach
    pass