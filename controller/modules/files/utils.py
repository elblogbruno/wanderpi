import os
import exifread
from datetime import datetime


STATIC_FOLDER = '/static/wanderpis/'
VIDEO_EXTENSIONS = set(['mp4'])
IMAGE_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif'])
# Allowed extension you can set your own
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif', 'mp4'])

def get_file_extension(filename):
    if '.' in filename:
        return filename.rsplit('.', 1)[1].lower()
    else:
        return 'mp4'

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

#convert degree minute second to degree decimal
def dms_to_dd(dms):
    dd = float(dms[0]) + float(dms[1])/60 + float(dms[2])/3600
    return float(dd)

def get_lat_long_tags(path_name):
    f = open(path_name, 'rb')

    tags = exifread.process_file(f, stop_tag='GPS')
    
    lat = 0
    long = 0

    for tag in tags.keys():
        if tag == 'GPS GPSLatitude':
            lat = dms_to_dd(tags[tag].values)
        elif tag == 'GPS GPSLongitude':
            long = dms_to_dd(tags[tag].values)
    
    if lat == 0 and long == 0:
        lat = 0
        long = 0

    return lat, long

def create_folder(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
    except OSError:
        print('Error: Creating directory. ' + directory)