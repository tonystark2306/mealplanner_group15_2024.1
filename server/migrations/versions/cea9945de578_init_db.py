"""init db

Revision ID: cea9945de578
Revises: 
Create Date: 2024-11-18 15:50:02.931746

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'cea9945de578'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('users',
    sa.Column('id', sa.String(length=36), nullable=False),
    sa.Column('email', sa.String(length=255), nullable=False),
    sa.Column('password_hash', sa.String(length=255), nullable=False),
    sa.Column('name', sa.String(length=100), nullable=False),
    sa.Column('language', sa.String(length=10), nullable=False),
    sa.Column('timezone', sa.String(length=50), nullable=False),
    sa.Column('is_verified', sa.Boolean(), nullable=False),
    sa.Column('deviceId', sa.String(length=255), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.Column('updated_at', sa.DateTime(), nullable=False),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('email')
    )
    op.create_table('groups',
    sa.Column('id', sa.String(length=36), nullable=False),
    sa.Column('group_name', sa.String(length=100), nullable=False),
    sa.Column('leader_id', sa.String(length=36), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.ForeignKeyConstraint(['leader_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('group_name')
    )
    op.create_table('login_attempts',
    sa.Column('id', sa.String(length=36), nullable=False),
    sa.Column('user_id', sa.String(length=36), nullable=False),
    sa.Column('attempt_time', sa.DateTime(), nullable=False),
    sa.Column('ip_address', sa.String(length=45), nullable=False),
    sa.Column('status', sa.String(length=50), nullable=False),
    sa.Column('user_agent', sa.String(length=255), nullable=True),
    sa.Column('is_remembered', sa.Boolean(), nullable=False),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('group_members',
    sa.Column('user_id', sa.String(length=36), nullable=False),
    sa.Column('group_id', sa.String(length=36), nullable=False),
    sa.Column('joined_at', sa.DateTime(), nullable=False),
    sa.ForeignKeyConstraint(['group_id'], ['groups.id'], ),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('user_id', 'group_id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('group_members')
    op.drop_table('login_attempts')
    op.drop_table('groups')
    op.drop_table('users')
    # ### end Alembic commands ###
