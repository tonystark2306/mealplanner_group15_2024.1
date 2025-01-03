"""add frigre items

Revision ID: d30cebc6ac28
Revises: a7928c3679a2
Create Date: 2024-11-19 00:11:21.863671

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'd30cebc6ac28'
down_revision = 'a7928c3679a2'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('fridge_items',
    sa.Column('group_id', sa.String(length=36), nullable=False),
    sa.Column('food_id', sa.String(length=36), nullable=False),
    sa.Column('quantity', sa.Double(), nullable=False),
    sa.Column('expiration_date', sa.DateTime(), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.ForeignKeyConstraint(['food_id'], ['foods.id'], ),
    sa.ForeignKeyConstraint(['group_id'], ['groups.id'], ),
    sa.PrimaryKeyConstraint('group_id', 'food_id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('fridge_items')
    # ### end Alembic commands ###
