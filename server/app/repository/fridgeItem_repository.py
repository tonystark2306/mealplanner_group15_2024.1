from .. import db
from datetime import datetime
from typing import List

from ..models.fridge_item import FridgeItem as FridgeItemModel
from .interface.fridgeItem_interface import FridgeInterface


class FridgeItemRepository(FridgeInterface):
    def __init__(self):
        pass

    def get_fridgeItem_by_group_id(self, group_id: str) -> List[FridgeItemModel]:
        return db.session.query(FridgeItemModel).filter_by(owner_id=group_id, status='active').all()
    

    # def get_fridgeItem_by_user_id(self, user_id: str) -> List[FridgeItemModel]:
    #     return FridgeItemModel.query.filter_by(owner_id=user_id, status='active').all()
    

    # def get_specific_fridgeItem(self, id: str) -> FridgeItemModel:
    #     return FridgeItemModel.query.filter_by(id=id, status='active').first()
    

    def add_item(self, owner_id: str, food_id: str, user_id: str, quantity: float, expiration_date: datetime) -> FridgeItemModel:
        new_item = FridgeItemModel(owner_id=owner_id, food_id=food_id, user_id=user_id, quantity=quantity, expiration_date=expiration_date)
        db.session.add(new_item)
        db.session.commit()
        return new_item
    

    # def update_item(self, id, owner_id: str, food_id: str, user_id: str, quantity: float, expiration_date: datetime) -> FridgeItemModel:
    #     item = FridgeItemModel.query.filter_by(id=id).first()
    #     item.quantity = quantity
    #     item.expiration_date = expiration_date
    #     db.session.commit()
    #     return item
    

    # def delete_item(self, id: str) -> FridgeItemModel:
    #     item = FridgeItemModel.query.get(id)
    #     item.status = 'deleted'
    #     db.session.commit()
    #     return item

