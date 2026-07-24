from .geosampa import geosampa_point_query
from core.utils.geo import within_city_bbox
from core.utils.text import normalize_geo_text
from .parsers.point_to_geojson import point_to_geojson
from config import CITY, FILTER_BY_CITY

from core.exceptions import OutofBounds

class LatLongSearch:

    def __init__(self)->None:

        self.geosampa = geosampa_point_query
        self.point_to_geojson = point_to_geojson
    
    
    def format_data(self, x:float, y:float, camadas)->dict:


        point = point_to_geojson(x, y)

        data = {
            'point' : point,
            'camadas_geosampa' : camadas
        }
        
        return data
    

    def __call__(self, x:float, y:float, convert_to_wgs_84:bool=True, **camadas)->None:
        # GeoSampa cobre a cidade de São Paulo. Fora dela (ex.: Itapevi),
        # não bloqueia o fluxo — devolve o ponto sem camadas.
        if FILTER_BY_CITY and not within_city_bbox(x, y):
            raise OutofBounds(f'Coordenadas devem estar dentro dos limites de {CITY}')

        if normalize_geo_text(CITY) not in ('sao paulo',):
            return self.format_data(x, y, {})

        camadas = self.geosampa(x, y, convert_to_wgs_84, **camadas)
        data = self.format_data(x, y, camadas)

        return data