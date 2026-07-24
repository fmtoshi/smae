from .geocoder import get_geocoder

from core.exceptions import OutofBounds
from core.utils.geo import within_city_bbox
from core.utils.text import matches_city_state_country
from config import CITY, STATE, COUNTRY_ISO, FILTER_BY_CITY

from typing import List

class ReverseGeocode:

    def __init__(self):

        self.geocoder = get_geocoder()

    def check_bbox(self, x:float, y:float)->None:
        """Verifica se as coordenadas estão dentro dos limites da cidade configurada"""
        if FILTER_BY_CITY and not within_city_bbox(x, y):
            raise OutofBounds(f'Coordenadas ({x}, {y}) fora dos limites de {CITY}')
    
    def is_sp(self, address:dict)->bool:
        """Verifica se o endereço corresponde à cidade/estado configurados"""
        if not FILTER_BY_CITY:
            return True
        
        return matches_city_state_country(
            address.get('properties') or {},
            CITY,
            STATE,
            COUNTRY_ISO,
        )
    
    def filter_address_sp(self, address_geojson:list)->List:
        """Filtra endereços pela cidade/estado configurados"""
        if not FILTER_BY_CITY:
            return
        
        in_city = [add for add in address_geojson['features']
                if self.is_sp(add)]
        address_geojson['features'] = in_city

    def pipeline(self, x:float, y:float)->dict:

        self.check_bbox(x, y)
        address = self.geocoder.reverse_geocode(x, y)
        self.filter_address_sp(address)

        return address
    
    
    def __call__(self, x:float, y:float)->dict:


        a = self.pipeline(x, y)
        print(a)

        return a