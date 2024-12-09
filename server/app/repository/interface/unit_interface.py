from abc import ABC, abstractmethod
from ...models.unit import Unit as UnitModel

class UnitInterface(ABC):


    @abstractmethod
    def get_unit_by_id(self, id) -> UnitModel:
        pass


    # @abstractmethod
    # def get_unit_by_name(self, name) -> UnitModel:
    #     pass


    # @abstractmethod
    # def get_all_units(self) -> list[UnitModel]:
    #     pass


    # @abstractmethod
    # def add_unit(self, name: str, symbol: str, description: str) -> UnitModel:
    #     pass


    # @abstractmethod
    # def update_unit(self, id: str, name: str, symbol: str, description: str) -> UnitModel:
    #     pass


    # @abstractmethod
    # def delete_unit(self, id: str) -> None:
    #     pass