from controller import create_app
from flask_sqlalchemy import SQLAlchemy
import db
from controller.models.models import Wanderpi

app = create_app('dev')

if __name__ == '__main__':
    #app.run(threaded=True, host="0.0.0.0")
    db.Base.metadata.create_all(db.engine)
    #app.run(threaded=True, host="0.0.0.0", port=5000)
    app.run(threaded=True, host="0.0.0.0", ssl_context='adhoc')   

