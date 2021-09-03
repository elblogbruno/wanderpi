from controller.modules.home.geocode_utils import GeoCodeUtils

from config import UPLOAD_FOLDER, load_custom_video_folder
from controller import create_app
from flask_sqlalchemy import SQLAlchemy
import db
from controller.models.models import Wanderpi
from controller import socketio
from flask_dropzone import Dropzone
from flask import send_from_directory
from config import STATIC_FOLDER
from controller.modules.files.utils import get_file_extension
import os
import json
import logging
from controller.utils.utils import ask_folder

dir_path = 'wanderpi.log'
logging.basicConfig(filename=dir_path, filemode='w', format='%(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# add the handler to the root logger
logging.getLogger('').addHandler(console)
logging.info("Log file will be saved to temporary path: {0}".format(dir_path))

custom_folder_path = ask_folder(logging)
load_custom_video_folder(custom_folder_path=custom_folder_path)    
app = create_app('dev')
droppzone = Dropzone(app)


@app.route('/wanderpi/<path:filename>')
def custom_static(filename):
    print("Serving this: " + str(filename))
    CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER = load_custom_video_folder()
    return send_from_directory(CUSTOM_STATIC_FOLDER, filename)

if __name__ == '__main__':
    db.Base.metadata.create_all(db.engine)
    app.jinja_env.cache = {}
    app.run(threaded=True, host="0.0.0.0", ssl_context=('/etc/letsencrypt/live/wanderpi.duckdns.org/fullchain.pem', '/etc/letsencrypt/live/wanderpi.duckdns.org/privkey.pem'))
