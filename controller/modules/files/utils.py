import os
import exifread
from datetime import datetime
from dateutil import parser
import re
import exiftool 

exif_Executable="./exiftool-exe/exiftool(-k).exe"    


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
        match_str = re.search(r'\d{4}-\d{2}-\d{2}', filename)
        if match_str:
            creation_datetime =  datetime.strptime(match_str.group(), '%Y-%m-%d').date()
        else:
            creation_datetime = datetime.today()
        print("Parsed datetime : " + str(creation_datetime))

    return lat, long, creation_datetime

def get_video_tags(path_name, filename):
    
    with exiftool.ExifTool(executable_=exif_Executable) as et:
        tags = et.get_metadata_batch([path_name])[0]
        
        std_fmt = '%Y:%m:%d %H:%M:%S+%M:%S'

        lat = 0
        long = 0
        creation_datetime  = 0
        duration = 0

        if 'Composite:GPSLatitude' in tags and 'Composite:GPSLongitude' in tags:
            lat = tags['Composite:GPSLatitude']
            long = tags['Composite:GPSLongitude']

        duration = tags['QuickTime:MediaDuration']
        create_date = str(tags['File:FileCreateDate'])
        creation_datetime = parser.parse(create_date)
    
        if creation_datetime == 0:
            try: 
                creation_datetime = parser.parse(filename,fuzzy=True)
            except:
                creation_datetime = datetime.today()

    return lat, long, creation_datetime, duration

def create_folder(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
    except OSError:
        print('Error: Creating directory. ' + directory)

