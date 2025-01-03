"""26_12_2024

Revision ID: b551a89d0a46
Revises: 57921567c771
Create Date: 2024-12-26 00:36:44.058877

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'b551a89d0a46'
down_revision = '57921567c771'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint('recipe_foods_food_id_fkey', 'recipe_foods', type_='foreignkey')
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_foreign_key('recipe_foods_food_id_fkey', 'recipe_foods', 'foods', ['food_id'], ['id'])
    # ### end Alembic commands ###
