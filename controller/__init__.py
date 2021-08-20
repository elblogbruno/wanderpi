import logging
from logging.handlers import RotatingFileHandler
from flask import Flask
from config import config_dict, load_custom_video_folder, STATIC_FOLDER
from flask_sqlalchemy import SQLAlchemy
from flask_socketio import SocketIO



def setup_log(log_level):
   
    logging.basicConfig(level=log_level)  
    
    file_log_handler = RotatingFileHandler("logs/log", maxBytes=1024 * 1024 * 100, backupCount=10)
    
    formatter = logging.Formatter('%(levelname)s %(pathname)s:%(lineno)d %(message)s')
    
    file_log_handler.setFormatter(formatter)
    
    logging.getLogger().addHandler(file_log_handler)

socketio = SocketIO(async_mode='threading')

def create_app(config_type):  
    config_class = config_dict[config_type]
    CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER  = load_custom_video_folder()
    app = Flask(__name__, static_folder=STATIC_FOLDER)
    app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

    app.config.from_object(config_class)
    
    from controller.modules.home import home_blu
    app.register_blueprint(home_blu)
    from controller.modules.user import user_blu
    app.register_blueprint(user_blu)
    # from controller.modules.video import video_blu
    # app.register_blueprint(video_blu)
    from controller.modules.travel import travel_blu
    app.register_blueprint(travel_blu)
    from controller.modules.record import record_blu
    app.register_blueprint(record_blu)
    from controller.modules.files import files_blu
    app.register_blueprint(files_blu)
    from controller.modules.files_utils import files_utils_blu
    app.register_blueprint(files_utils_blu)
    setup_log(config_class.LOG_LEVEL)
    
    socketio.init_app(app)

    return app
