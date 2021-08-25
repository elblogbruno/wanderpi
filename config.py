import logging
import os
import json
from datetime import timedelta
from controller.utils.utils import create_folder
#UPLOAD_FOLDER = os.getcwd()+'/uploads/'
#/mnt/wanderpi/controller/static/wanderpis/ec38b9af-2eaf-41c4-a428-1b2e5a827d67/images
#CUSTOM_STATIC_FOLDER = "/mnt/wanderpi"
STATIC_FOLDER = os.getcwd()+'/controller/static/'

UPLOAD_FOLDER = None
CUSTOM_STATIC_FOLDER = None
VIDEOS_FOLDER = None

def load_custom_video_folder(custom_folder_path=None):
    global CUSTOM_STATIC_FOLDER
    global VIDEOS_FOLDER
    global UPLOAD_FOLDER
    print(CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER)

    if custom_folder_path:
        CUSTOM_STATIC_FOLDER = custom_folder_path
        VIDEOS_FOLDER = CUSTOM_STATIC_FOLDER+'wanderpis/'
        create_folder(VIDEOS_FOLDER)
        UPLOAD_FOLDER = CUSTOM_STATIC_FOLDER+'uploads/'
        create_folder(UPLOAD_FOLDER)
        print("Custom folder from json file")
        return CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER
    else:
        print("Custom folder already loaded")
        return CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER

class Config:
    
    DEBUG = True
    SECRET_KEY = "fM3PEZwSRcbLkk2Ew82yZFffdAYsNgOddWoANdQo/U3VLZ/qNsOKLsQPYXDPon2t"

    MAX_CONTENT_LENGTH  = 200 * 1024 * 1024

    DROPZONE_MAX_FILE_SIZE= 1024  # set max size limit to a large number, here is 1024 MB
    DROPZONE_TIMEOUT=5 * 60 * 1000  # set upload timeout to a large number, here is 5 minutes
    DROPZONE_MAX_FILES=100
    DROPZONE_PARALLEL_UPLOADS=4  # set parallel amount
    DROPZONE_UPLOAD_MULTIPLE=True  # enable upload multiple
    #DROPZONE_REDIRECT_VIEW='files.completed'  # set redirect view
    PERMANENT_SESSION_LIFETIME = timedelta(days=7)

class DevelopmentConfig(Config):
    DEBUG = True
    LOG_LEVEL = logging.DEBUG
    

class ProductionConfig(Config):
    DEBUG = False
    LOG_LEVEL = logging.ERROR  


config_dict = {
    'dev': DevelopmentConfig,
    'pro': ProductionConfig
}
