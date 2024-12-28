"""add cooking_time recipe

Revision ID: ec26c0e59aa0
Revises: e682bcd3afe9
Create Date: 2024-12-26 23:12:23.684732

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'ec26c0e59aa0'
down_revision = 'e682bcd3afe9'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('recipes', sa.Column('cooking_time', sa.Float(), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('recipes', 'cooking_time')
    # ### end Alembic commands ###
