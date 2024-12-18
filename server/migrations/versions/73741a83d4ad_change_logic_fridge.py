"""change logic fridge

Revision ID: 73741a83d4ad
Revises: b015ccba257b
Create Date: 2024-11-29 23:04:13.915993

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '73741a83d4ad'
down_revision = 'b015ccba257b'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('fridge_items')
    op.add_column('group_members', sa.Column('status', sa.String(length=10), nullable=False))
    op.add_column('shopping_lists', sa.Column('assigned_to', sa.String(length=36), nullable=True))
    op.add_column('shopping_lists', sa.Column('due_time', sa.DateTime(), nullable=True))
    op.create_foreign_key(None, 'shopping_lists', 'users', ['assigned_to'], ['id'])
    op.drop_column('shopping_lists', 'assigned_username')
    op.drop_column('shopping_lists', 'due_date')
    op.add_column('shopping_tasks', sa.Column('status', sa.String(length=10), nullable=False))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('shopping_tasks', 'status')
    op.add_column('shopping_lists', sa.Column('due_date', postgresql.TIMESTAMP(), autoincrement=False, nullable=True))
    op.add_column('shopping_lists', sa.Column('assigned_username', sa.VARCHAR(length=100), autoincrement=False, nullable=True))
    op.drop_constraint(None, 'shopping_lists', type_='foreignkey')
    op.drop_column('shopping_lists', 'due_time')
    op.drop_column('shopping_lists', 'assigned_to')
    op.drop_column('group_members', 'status')
    op.create_table('fridge_items',
    sa.Column('group_id', sa.VARCHAR(length=36), autoincrement=False, nullable=False),
    sa.Column('food_id', sa.VARCHAR(length=36), autoincrement=False, nullable=False),
    sa.Column('quantity', sa.DOUBLE_PRECISION(precision=53), autoincrement=False, nullable=False),
    sa.Column('expiration_date', postgresql.TIMESTAMP(), autoincrement=False, nullable=False),
    sa.Column('created_at', postgresql.TIMESTAMP(), autoincrement=False, nullable=False),
    sa.ForeignKeyConstraint(['food_id'], ['foods.id'], name='fridge_items_food_id_fkey'),
    sa.ForeignKeyConstraint(['group_id'], ['groups.id'], name='fridge_items_group_id_fkey'),
    sa.PrimaryKeyConstraint('group_id', 'food_id', name='fridge_items_pkey')
    )
    # ### end Alembic commands ###
