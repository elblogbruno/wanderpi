import os
import exifread
from datetime import datetime
from dateutil import parser
import re
import exiftool 
import io
import os

exif_Executable="./exiftool-exe/exiftool(-k).exe"    
exif_executable_raspberry = "exiftool"

STATIC_FOLDER = '/static/wanderpis/'
VIDEO_EXTENSIONS = set(['mp4'])
IMAGE_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif'])
# Allowed extension you can set your own
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif', 'mp4'])

def is_raspberrypi():
    if os.name != 'posix':
        return False
    chips = ('BCM2708','BCM2709','BCM2711','BCM2835','BCM2836')
    try:
        with io.open('/proc/cpuinfo', 'r') as cpuinfo:
            for line in cpuinfo:
                if line.startswith('Hardware'):
                    _, value = line.strip().split(':', 1)
                    value = value.strip()
                    if value in chips:
                        return True
    except Exception:
        pass
    return False

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

def get_file_tags(path_name, filename, file_type='image'):
    # try:
    ex_path = exif_executable_raspberry if is_raspberrypi() else exif_Executable
    with exiftool.ExifTool(executable_=ex_path) as et:
        tags = et.get_metadata_batch([path_name])[0]
        print(tags)
        
        std_fmt_time = '%Y:%m:%d %H:%M:%S+%M:%S'
        std_fmt = '%Y:%m:%d %H:%M:%S'
        
        is_360 = 'XMP:ProjectionType' in tags
        print("Image is 360? " + str(is_360))
        lat = 0
        long = 0
        creation_datetime  = 0
        duration = 0
        
        if file_type == 'video':
            duration = tags['QuickTime:MediaDuration']

        if 'Composite:GPSLatitude' in tags and 'Composite:GPSLongitude' in tags:
            lat = tags['Composite:GPSLatitude']
            long = tags['Composite:GPSLongitude']

        has_time = False
        create_date = None
        if 'File:FileCreateDate' in tags:
            create_date = str(tags['File:FileCreateDate'])
            print('File:FileCreateDate: ' + create_date)
        elif 'EXIF:DateTimeOriginal' in tags:
            create_date = str(tags['EXIF:DateTimeOriginal'])
            print('EXIF:DateTimeOriginal: ' + create_date)
        else:
            match_str = re.search(r'\d{4}-\d{2}-\d{2}', filename)
            if match_str:
                print(match_str.group())
                creation_datetime =  datetime.strptime(match_str.group(), '%Y-%m-%d').date()
            else:
                creation_datetime = datetime.today()
        
        if has_time and create_date:
            creation_datetime = datetime.strptime(create_date, std_fmt_time)
        elif create_date:
            creation_datetime = datetime.strptime(create_date, std_fmt)

            
        
        
        
        print("Parsed datetime : " + str(creation_datetime))

    if file_type == 'image':
        return lat, long, creation_datetime, is_360
    else:
        return lat, long, creation_datetime, duration, is_360
    # except:
    #     print("Error")
    #     if file_type == 'image':
    #         return 0, 0, datetime.today(), False
    #     else:
    #         return 0, 0, datetime.today(), -1, False

# def get_video_tags(path_name, filename):
#     try:
#         ex_path = exif_executable_raspberry if is_raspberrypi() else exif_Executable
#         with exiftool.ExifTool(executable_=ex_path) as et:
#             tags = et.get_metadata_batch([path_name])[0]
#             print(tags)
#             std_fmt = '%Y:%m:%d %H:%M:%S+%M:%S'
#             is_360 = 'XMP:ProjectionType' in tags
#             lat = 0
#             long = 0
#             creation_datetime  = 0
#             duration = 0

#             if 'Composite:GPSLatitude' in tags and 'Composite:GPSLongitude' in tags:
#                 lat = tags['Composite:GPSLatitude']
#                 long = tags['Composite:GPSLongitude']

#             duration = tags['QuickTime:MediaDuration']
#             create_date = str(tags['File:FileCreateDate'])
#             creation_datetime = parser.parse(create_date)
        
#             if creation_datetime == 0:
#                 match_str = re.search(r'\d{4}-\d{2}-\d{2}', filename)
#                 if match_str:
#                     creation_datetime =  datetime.strptime(match_str.group(), '%Y-%m-%d').date()
#                 else:
#                     creation_datetime = datetime.today()
#                 print("Parsed datetime : " + str(creation_datetime))

#         return lat, long, creation_datetime, duration, is_360
#     except:
#         return 0, 0, datetime.today(), 0, False

