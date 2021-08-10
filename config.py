import logging
import os
from datetime import timedelta

UPLOAD_FOLDER = os.getcwd()+'/uploads/'
STATIC_FOLDER = os.getcwd()+'/controller/static/'
VIDEOS_FOLDER = os.getcwd()+'/controller/static/wanderpis/'


class Config:
    
    DEBUG = True
    SECRET_KEY = "fM3PEZwSRcbLkk2Ew82yZFffdAYsNgOddWoANdQo/U3VLZ/qNsOKLsQPYXDPon2t"

    MAX_CONTENT_LENGTH  = 200 * 1024 * 1024

    DROPZONE_MAX_FILE_SIZE= 1024  # set max size limit to a large number, here is 1024 MB
    DROPZONE_TIMEOUT=5 * 60 * 1000  # set upload timeout to a large number, here is 5 minutes
    DROPZONE_MAX_FILES=30
    DROPZONE_PARALLEL_UPLOADS=3  # set parallel amount
    DROPZONE_UPLOAD_MULTIPLE=True  # enable upload multiple
    DROPZONE_REDIRECT_VIEW='files.completed'  # set redirect view
    PERMANENT_SESSION_LIFETIME = timedelta(days=7)


class DevelopmentConfig(Config):
    DEBUG = True
    LOG_LEVEL = logging.DEBUG
    UPLOAD_FOLDER = UPLOAD_FOLDER

class ProductionConfig(Config):
    DEBUG = False
    LOG_LEVEL = logging.ERROR  


config_dict = {
    'dev': DevelopmentConfig,
    'pro': ProductionConfig
}
