from typing import List
from abc import ABC, abstractmethod
from ...models.unit import Unit as UnitModel

class UnitInterface(ABC):
    def __init__(self):
        pass

    @abstractmethod
    def get_unit_by_id(self, id) -> UnitModel:
        pass


    @abstractmethod
    def get_unit_by_name(self, name) -> UnitModel:
        pass
    
    @abstractmethod
    def get_all_system_units(self) -> List[UnitModel]:
        pass
    
    @abstractmethod
    def create_system_unit(self, unit_name) -> UnitModel:
        pass
    
    @abstractmethod
    def update_name_for_unit(self, unit, new_name):
        pass
    
    @abstractmethod
    def delete_unit(self, unit):
        pass