import json 
import urllib

import geopy
from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter
import reverse_geocoder as rg

class GeoCodeUtils:
    @staticmethod
    def reverse_search_offline(lon, lat):
        """Function that having a lat and long searches for a place in the txt file allCountries.txt 
            and returns the name of the place
        """
        results = rg.search((lon,lat)) # default mode = 2

        return results[0]['name']

    @staticmethod
    def reverse_latlong(lat,long):
        """Function that having a lat and long translates it to a posiblea ddress"
        """
        #check if user has internet connection
        if lat == 0 and long == 0:
            return "Location unknown"
            
        if not GeoCodeUtils.has_internet_connection():
            return GeoCodeUtils.reverse_search_offline(lat, long)
        else:
            locator = Nominatim(user_agent="openmapquest")
            coordinates = "{0}, {1}".format(lat, long)
            try:
                location = locator.reverse(coordinates)
                print(location)
                if location:
                    if 'town' in location.raw and 'country' in location.raw and 'state' in location.raw:
                        return location.raw['address']['town'] + ", " + location.raw['address']['state'] + ", " + location.raw['address']['country']
                    else:
                        return location.address
                else:
                    return "Location unknown"
            except geopy.exc.GeocoderUnavailable as e:
                return GeoCodeUtils.reverse_search_offline(lat, long)

                

    @staticmethod
    def reverse_address(address):
        """Function that having an adress translates it to a lat and long values"
        """
        locator = Nominatim(user_agent="openmapquest")
        try:
            location = locator.geocode(address)
            print(location)
            if location:
                return location.latitude, location.longitude
            else:
                return 0,0
        except geopy.exc.GeocoderUnavailable as e:
                return 0,0


    @staticmethod
    def has_internet_connection():
        """Function that checks if the user has an internet connection"""
        try:
            urllib.request.urlopen('https://www.google.com/', timeout=1)
            return True
        except urllib.error.URLError as err:
            return False
        except socket.timeout as err:
            return False