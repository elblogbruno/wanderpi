from controller import create_app
from flask_sqlalchemy import SQLAlchemy
app = create_app('dev')
db = SQLAlchemy(app)

if __name__ == '__main__':
    #app.run(threaded=True, host="0.0.0.0")
    db.create_all()
    app.run(threaded=True, host="0.0.0.0", ssl_context='adhoc')

