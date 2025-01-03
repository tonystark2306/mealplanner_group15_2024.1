"""change from leader to admin

Revision ID: 105680214b56
Revises: cea9945de578
Create Date: 2024-11-18 15:53:59.168752

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '105680214b56'
down_revision = 'cea9945de578'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('groups', sa.Column('admin_id', sa.String(length=36), nullable=False))
    op.drop_constraint('groups_leader_id_fkey', 'groups', type_='foreignkey')
    op.create_foreign_key(None, 'groups', 'users', ['admin_id'], ['id'])
    op.drop_column('groups', 'leader_id')
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('groups', sa.Column('leader_id', sa.VARCHAR(length=36), autoincrement=False, nullable=False))
    op.drop_constraint(None, 'groups', type_='foreignkey')
    op.create_foreign_key('groups_leader_id_fkey', 'groups', 'users', ['leader_id'], ['id'])
    op.drop_column('groups', 'admin_id')
    # ### end Alembic commands ###
