from werkzeug.security import generate_password_hash, check_password_hash

class Wanderpi(db.Model):
    __tablename__ = 'video'
    id = db.Column(db.String(256), primary_key=True)
    name = db.Column(db.String(256), nullable=False)
    lat = db.Column(db.String(256), nullable=False)
    long = db.Column(db.String(256), nullable=False)

    

    def __repr__(self):
        return f'<User {self.id}>'
    def set_id(self, id):
        self.id = id
        
    def save(self):
        if not self.id:
            db.session.add(self)
        db.session.commit()
        
    @staticmethod
    def get_by_id(id):
        return Wanderpi.query.get(id)
    
    @staticmethod
    def get_all():
        return Wanderpi.query.all()