import os
import exifread
from datetime import datetime
import dateutil.parser as dparser

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

def get_image_tags(path_name, filename):
    f = open(path_name, 'rb')

    tags = exifread.process_file(f, stop_tag='GPS')
    std_fmt = '%Y:%m:%d %H:%M:%S'

    lat = 0
    long = 0
    creation_datetime  = 0

    for tag in tags.keys():
        if tag == 'GPS GPSLatitude':
            lat = dms_to_dd(tags[tag].values)
        elif tag == 'GPS GPSLongitude':
            long = dms_to_dd(tags[tag].values)
        elif tag == 'EXIF DateTimeOriginal':
            creation_datetime = datetime.strptime(tags['EXIF DateTimeOriginal'].values, std_fmt)
    
    if creation_datetime == 0:
        creation_datetime = dparser.parse(filename,fuzzy=True)

    return lat, long, creation_datetime

def get_video_tags(path_name, filename):
    f = open(path_name, 'rb')

    tags = exifread.process_file(f, stop_tag='GPS')
    std_fmt = '%Y:%m:%d %H:%M:%S.%f'

    lat = 0
    long = 0
    creation_datetime  = 0

    for tag in tags.keys():
        if tag == 'GPS GPSLatitude':
            lat = dms_to_dd(tags[tag].values)
        elif tag == 'GPS GPSLongitude':
            long = dms_to_dd(tags[tag].values)
        elif tag == 'EXIF DateTimeOriginal':
            creation_datetime = datetime.strptime(tags['EXIF DateTimeOriginal'].values, std_fmt)
    
    if creation_datetime == 0:
        try: 
            creation_datetime = dparser.parse(filename,fuzzy=True)
        except:
            creation_datetime = datetime.today()

    return lat, long, creation_datetime

def create_folder(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
    except OSError:
        print('Error: Creating directory. ' + directory)

