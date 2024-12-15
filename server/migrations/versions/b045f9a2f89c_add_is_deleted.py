"""add is_deleted

Revision ID: b045f9a2f89c
Revises: 700f0ee2a2cd
Create Date: 2024-12-13 00:24:14.357119

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'b045f9a2f89c'
down_revision = '700f0ee2a2cd'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('recipe_images', sa.Column('updated_at', sa.DateTime(), nullable=False))
    op.add_column('recipe_images', sa.Column('is_deleted', sa.Integer(), nullable=False))
    op.add_column('recipes', sa.Column('updated_at', sa.DateTime(), nullable=False))
    op.add_column('recipes', sa.Column('is_deleted', sa.Integer(), nullable=False))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('recipes', 'is_deleted')
    op.drop_column('recipes', 'updated_at')
    op.drop_column('recipe_images', 'is_deleted')
    op.drop_column('recipe_images', 'updated_at')
    # ### end Alembic commands ###