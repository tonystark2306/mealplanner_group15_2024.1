"""add group_id to tables to make custom attribute

Revision ID: 6ce1e8a359b9
Revises: 48bed66a7613
Create Date: 2024-12-06 22:13:05.936438

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6ce1e8a359b9'
down_revision = '48bed66a7613'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('categories', sa.Column('type', sa.String(length=50), nullable=False))
    op.add_column('categories', sa.Column('group_id', sa.String(length=36), nullable=True))
    op.create_foreign_key(None, 'categories', 'groups', ['type'], ['id'])
    op.add_column('foods', sa.Column('group_id', sa.String(length=36), nullable=True))
    op.create_foreign_key(None, 'foods', 'groups', ['group_id'], ['id'])
    op.add_column('recipes', sa.Column('type', sa.String(length=50), nullable=True))
    op.add_column('recipes', sa.Column('group_id', sa.String(length=36), nullable=True))
    op.alter_column('recipes', 'content_html',
               existing_type=sa.TEXT(),
               nullable=True)
    op.alter_column('recipes', 'description',
               existing_type=sa.TEXT(),
               nullable=True)
    op.add_column('units', sa.Column('type', sa.String(length=50), nullable=False))
    op.add_column('units', sa.Column('group_id', sa.String(length=36), nullable=True))
    op.create_foreign_key(None, 'units', 'groups', ['group_id'], ['id'])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(None, 'units', type_='foreignkey')
    op.drop_column('units', 'group_id')
    op.drop_column('units', 'type')
    op.alter_column('recipes', 'description',
               existing_type=sa.TEXT(),
               nullable=False)
    op.alter_column('recipes', 'content_html',
               existing_type=sa.TEXT(),
               nullable=False)
    op.drop_column('recipes', 'group_id')
    op.drop_column('recipes', 'type')
    op.drop_constraint(None, 'foods', type_='foreignkey')
    op.drop_column('foods', 'group_id')
    op.drop_constraint(None, 'categories', type_='foreignkey')
    op.drop_column('categories', 'group_id')
    op.drop_column('categories', 'type')
    # ### end Alembic commands ###