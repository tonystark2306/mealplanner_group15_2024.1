from typing import List
from .. import db
from abc import ABC, abstractmethod

from ..models.unit import Unit as UnitModel
from .interface.unit_interface import UnitInterface

class UnitRepository(UnitInterface):


    def get_unit_by_id(self, id) -> UnitModel:
        return db.session.query(UnitModel).filter_by(id=id).first()