"""add avatar group

Revision ID: b015ccba257b
Revises: 0681d8553c74
Create Date: 2024-11-21 23:14:08.514902

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'b015ccba257b'
down_revision = '0681d8553c74'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('groups', sa.Column('group_avatar', sa.String(length=255), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('groups', 'group_avatar')
    # ### end Alembic commands ###
