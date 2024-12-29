"""Add 3 fields 'reset_token', 'reset_code', 'reset_code_expires_at' into table 'tokens'

Revision ID: 290e90beb5db
Revises: f69f578f9e06
Create Date: 2024-12-29 02:04:10.629573

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '290e90beb5db'
down_revision = 'f69f578f9e06'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('tokens', schema=None) as batch_op:
        batch_op.add_column(sa.Column('reset_token', sa.String(length=255), nullable=True))
        batch_op.add_column(sa.Column('reset_code', sa.String(length=255), nullable=True))
        batch_op.add_column(sa.Column('reset_code_expires_at', sa.DateTime(), nullable=True))
        batch_op.create_unique_constraint(None, ['reset_code'])
        batch_op.create_unique_constraint(None, ['reset_token'])



    # ### end Alembic commands ###


def downgrade():


    with op.batch_alter_table('tokens', schema=None) as batch_op:
        batch_op.drop_constraint(None, type_='unique')
        batch_op.drop_constraint(None, type_='unique')
        batch_op.drop_column('reset_code_expires_at')
        batch_op.drop_column('reset_code')
        batch_op.drop_column('reset_token')

    # ### end Alembic commands ###