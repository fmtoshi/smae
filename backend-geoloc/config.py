from dotenv import load_dotenv
import os

def load_env(var_name:str)->str:

    load_dotenv()
    try:
        return os.environ[var_name]
    except KeyError:
        raise RuntimeError(f'Variável de ambiente {var_name} não definida!')
    
def str_to_bool(var_name:str)->bool:

    var_value = load_env(var_name)

    if var_value.lower() == 'false':
        return False
    if var_value.lower() == 'true':
        return True
    
    raise RuntimeError(f'Variável de ambiente {var_name} é booleana. Definir como (true, false). Definida como: {var_value}')

def str_to_bool_optional(var_value:str, default:bool=True)->bool:
    """Converte string para bool, com valor padrão se não definido"""
    if not var_value:
        return default
    if var_value.lower() == 'false':
        return False
    if var_value.lower() == 'true':
        return True
    return default

CITY=load_env('CITY')
STATE=load_env('STATE')
COUNTRY_ISO=load_env('COUNTRY_ISO')

# Permite desabilitar o filtro geográfico para aceitar qualquer cidade
# Se definido como 'false', não filtra por cidade/estado
FILTER_BY_CITY = str_to_bool_optional(os.environ.get('FILTER_BY_CITY', 'true'), default=True)

NOMINATIM_EMAIL=load_env('NOMINATIM_EMAIL')

GEOSAMPA_WFS_DOMAIN=load_env('GEOSAMPA_WFS_DOMAIN')
GEOSAMPA_API_VERSION=load_env('GEOSAMPA_API_VERSION')
DISTANCIA_PADRAO_MTS_GEOSAMPA=load_env('DISTANCIA_PADRAO_MTS_GEOSAMPA')


GEOM_TYPES = (
    'Geometry',
    'LineString',
    'MultiLineString',
    'MultiPolygon',
    'Point',
    'Polygon'
)

NAMES_CAMADAS_TTL_SECONDS=load_env('NAMES_CAMADAS_TTL_SECONDS')


#esta no formato long lat
SAO_PAULO_WGS_BOUNDING_BOX = ((-46.809319, -23.784969), (-46.36499, -23.39566))

# Bounding box de Itapevi (limites OSM + margem ampla)
# Formato: ((longitude_min, latitude_min), (longitude_max, latitude_max))
# OSM aprox.: S -23.603795, W -47.030183, N -23.498651, E -46.907381
# Margem ampliada para cobrir bordas com Jandira/Barueri/Cotia e pontos retornados pelo Nominatim
ITAPEVI_WGS_BOUNDING_BOX = ((-47.10, -23.66), (-46.85, -23.45))

# Seleciona o bounding box baseado na cidade configurada
if CITY.lower() == "itapevi":
    CITY_WGS_BOUNDING_BOX = ITAPEVI_WGS_BOUNDING_BOX
else:
    # Default para São Paulo ou outras cidades
    CITY_WGS_BOUNDING_BOX = SAO_PAULO_WGS_BOUNDING_BOX

WGS84_EPSG=4326

AZURE_KEY = load_env('AZURE_KEY')
USE_AZURE = str_to_bool('USE_AZURE')
GEOSAMPA_LAYER_PREFIX = load_env('GEOSAMPA_LAYER_PREFIX')

MAX_ADDRESSES=int(load_env('MAX_ADDRESSES'))