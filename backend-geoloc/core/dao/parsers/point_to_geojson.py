from core.utils.geo import geojson_envelop

from config import CITY_WGS_BOUNDING_BOX, WGS84_EPSG


def point_to_geojson(x:float, y:float)->dict:         
        
        feature = {
                    "type": "Feature",
                    "properties": {
                    },
                    "geometry" : {
                    "type": "Point",
                    "coordinates": [x, y]
                    }
                    }
        
        feature['bbox']=[
                        CITY_WGS_BOUNDING_BOX[0][0],
                        CITY_WGS_BOUNDING_BOX[0][1],
                        CITY_WGS_BOUNDING_BOX[1][0],
                        CITY_WGS_BOUNDING_BOX[1][1]
                    ]
        
        geojson = geojson_envelop([feature], WGS84_EPSG)
        
        
        return geojson