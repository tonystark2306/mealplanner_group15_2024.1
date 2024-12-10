import logging
from typing import List

from sqlalchemy import and_

from .. import db
from ..models.unit import Unit as UnitModel
from .interface.unit_interface import UnitInterface


class UnitRepository(UnitInterface):
    def __init__(self):
        pass


    def get_unit_by_id(self, id) -> UnitModel:
        return db.session.query(UnitModel).filter_by(id=id).first()
    
    
    def get_unit_by_name(self, name):
        return db.session.execute(
            db.select(UnitModel).where(
                and_(
                    UnitModel.type == "system",
                    UnitModel.name == name
                )
            )
        ).scalar()
        
        
    def get_all_system_units(self) -> List[UnitModel]:
        return db.session.execute(
            db.select(UnitModel).where(UnitModel.type == "system")
        ).scalars().all()
        
        
    def create_system_unit(self, unit_name):
        try:
            new_unit = UnitModel(
                name=unit_name,
                type="system"
            )
            db.session.add(new_unit)
            db.session.commit()
            return new_unit
        
        except Exception as e:
            db.session.rollback()
            logging.error(f"Error creating system unit: {str(e)}")
            raise