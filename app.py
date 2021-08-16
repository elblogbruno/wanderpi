from controller.modules.home.geocode_utils import GeoCodeUtils

from config import UPLOAD_FOLDER
from controller import create_app
from flask_sqlalchemy import SQLAlchemy
import db
from controller.models.models import Wanderpi
from controller import socketio
from flask_dropzone import Dropzone
from flask import send_from_directory
from config import STATIC_FOLDER
app = create_app('dev')
droppzone = Dropzone(app)


@app.route("/static/<path:path>")
def static_dir(path):
    print(path)
    return send_from_directory(STATIC_FOLDER, path)


if __name__ == '__main__':
    #app.run(threaded=True, host="0.0.0.0")
    db.Base.metadata.create_all(db.engine)
    
    app.run(threaded=True, host="0.0.0.0", ssl_context='adhoc')
    # w = threading.Thread(target=ImagesWatcher(UPLOAD_FOLDER).run())

    # w.start()
    # t.start()
