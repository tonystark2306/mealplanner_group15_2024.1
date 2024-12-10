import logging
from ...repository.unit_repository import UnitRepository


class UnitService:
    def __init__(self):
        self.unit_repository = UnitRepository()    
    
    
    def get_unit_by_name(self, name):
        """ Get a system unit by name """
        return self.unit_repository.get_unit_by_name(name)
    
    
    def list_system_units(self):
        """ List all system units """
        return self.unit_repository.get_all_system_units()
    
    
    def create_unit_for_system(self, unit_name):
        """ Create a unit for the system """
        try:
            new_unit = self.unit_repository.create_system_unit(unit_name)
            return new_unit
        except Exception as e:
            logging.error(f"Error creating system unit: {str(e)}")
            raise
    
    
    def update_unit_name(self, unit, new_name):
        """ Update the name of a unit """
        try:
            self.unit_repository.update_name_for_unit(unit, new_name)
        except Exception as e:
            logging.error(f"Error updating unit name: {str(e)}")
            raise
        
        
    def delete_unit(self, unit):
        """ Delete a system unit"""
        try:
            self.unit_repository.delete_unit(unit)
        except Exception as e:
            logging.error(f"Error deleting system unit: {str(e)}")
            raise