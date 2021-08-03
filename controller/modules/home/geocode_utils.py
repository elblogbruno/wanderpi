import json 
import urllib

import geopy
from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter

class GeoCodeUtils:

    @staticmethod
    def reverse_latlong(lat,long):
        """Function that having a lat and long translates it to a posiblea ddress"
        """
        locator = Nominatim(user_agent="openmapquest")
        coordinates = "{0}, {1}".format(lat, long)
        location = locator.reverse(coordinates)
        
        return location.address

    @staticmethod
    def reverse_address(address):
        """Function that having an adress translates it to a lat and long values"
        """
        locator = Nominatim(user_agent="openmapquest")
        location = locator.geocode(address)
        print(location)
        return location.latitude, location.longitude