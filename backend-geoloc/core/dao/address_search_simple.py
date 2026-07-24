from .geocoder import get_geocoder
from typing import List
from config import MAX_ADDRESSES, CITY, STATE, COUNTRY_ISO, FILTER_BY_CITY
from core.utils.text import matches_city_state_country
from core.utils.geo import geojson_envelop

class AddresSearchSimple:

    def __init__(self):

       self.geocoder = get_geocoder()

    
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

    def limit_response(self, address_geojson)->List[dict]:

        address_geojson['features'] = address_geojson['features'][:MAX_ADDRESSES]   
    
    def __call__(self, address:str)->List[dict]:

   
        geocode_resp = self.geocoder.geocode(address)
        self.filter_address_sp(geocode_resp)
        self.limit_response(geocode_resp)

        return geocode_resp
            


    
    
    



