from werkzeug.security import generate_password_hash, check_password_hash
import db
from sqlalchemy import Column, Integer, String, Float, DateTime, Text
from datetime import datetime

class Wanderpi(db.Base):
    __tablename__ = 'video'
    id = Column(String(256), primary_key=True)
    name = Column(String(256), nullable=False)
    lat = Column(String(256), nullable=False)
    long = Column(String(256), nullable=False)
    thumbnail_url = Column(String(256), nullable=False)
    created_date = Column(DateTime, default=datetime.utcnow)
    

    def __repr__(self):
        return f'<User {self.id}>'

    def set_id(self, id):
        self.id = id

    def set_name(self, id):
        self.id = id
           
    def save(self):
        db.session.add(self)
        db.session.commit()
    
    @staticmethod
    def delete(id):
        db.session.query(Wanderpi).filter(Wanderpi.id == id).delete()
        db.session.commit()
        return True


    @staticmethod
    def get_by_id(id):
        return db.session.query(Wanderpi).get(id)
    
    @staticmethod
    def get_all():
        return db.session.query(Wanderpi).all()