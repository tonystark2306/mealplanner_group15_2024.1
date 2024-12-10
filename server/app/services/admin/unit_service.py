import logging
from ...repository.unit_repository import UnitRepository


class UnitService:
    def __init__(self):
        self.unit_repository = UnitRepository()    
    
    
    def get_unit_by_name(self, name):
        """ Get a system unit by name """
        return self.unit_repository.get_unit_by_name(name)
    
    
    def create_unit_for_system(self, unit_name):
        """ Create a unit for the system """
        try:
            new_unit = self.unit_repository.create_system_unit(unit_name)
            return new_unit
        except Exception as e:
            logging.error(f"Error creating system unit: {str(e)}")
            raise
    
    