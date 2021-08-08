from werkzeug.security import generate_password_hash, check_password_hash
import db
from sqlalchemy import Column, Boolean, String, Float, DateTime, Text, Date, Time, desc
from datetime import datetime
import os
import json
import shutil

def datetime_parser(o):
    if isinstance(o, datetime):
        return o.__str__()
class Wanderpi(db.Base):
    __tablename__ = 'wanderpi'
    id = Column(String(256), primary_key=True)
    name = Column(String(256), nullable=False)
    lat = Column(String(256), nullable=False)
    long = Column(String(256), nullable=False)
    address = Column(String(256), nullable=False)
    time_duration = Column(Float, nullable=False)
    file_thumbnail_path = Column(String(256), nullable=False)
    file_path = Column(String(256), nullable=False)
    created_date = Column(DateTime, default=datetime.utcnow)
    travel_id = Column(String(256), nullable=False)
    is_image = Column(Boolean)
    has_been_edited = Column(Boolean, default=False)

    def __repr__(self):
        return f'<User {self.id}>'

    def set_id(self, id):
        self.id = id

    def set_name(self, id):
        self.id = id
           
    def save(self):
        db.session.add(self)
        db.session.commit()
        #self.save_json()
    
    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

    # this functions gets the object as a dictionary and saves it to a json file
    def save_json(self):
        #write json file on path where file is located
        json_file_path = "./controller"+ os.path.dirname(self.file_path) + '/{0}.json'.format(self.id)
        print(json_file_path)
        with open(json_file_path, 'w') as f:
            json.dump(self.as_dict(), f, default = datetime_parser)

    def delete(self):
        if os.path.isfile(self.file_path):
            print("Removing file from disk")
            os.remove(self.file_path)

        db.session.query(Wanderpi).filter(Wanderpi.id == self.id).delete()
        db.session.commit()
        return True


    @staticmethod
    def get_by_id(id):
        return db.session.query(Wanderpi).get(id)
    
    @staticmethod
    def get_all():
        return db.session.query(Wanderpi).all()


class Travel(db.Base):
    __tablename__ = 'travel'
    id = Column(String(256), primary_key=True)
    name = Column(String(256), nullable=False)
    lat = Column(String(256), nullable=False)
    long = Column(String(256), nullable=False)
    travel_folder_path = Column(String(256), nullable=False)
    destination = Column(String(256), nullable=False)
    created_date = Column(DateTime, default=datetime.utcnow)
    start_date = Column(Date)
    end_date = Column(Date)
    

    def __repr__(self):
        return f'<User {self.id}>'

    def set_id(self, id):
        self.id = id

    def set_name(self, id):
        self.id = id
           
    def save(self):
        print(self.start_date)
        db.session.add(self)
        db.session.commit()
        self.save_json()
    
    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}
    # this functions gets the object as a dictionary and saves it to a json file
    def save_json(self):
        #write json file on path where file is located
        json_file_path = self.travel_folder_path + '/{0}.json'.format(self.id)

        with open(json_file_path, 'w') as f:
            json.dump(self.as_dict(), f, default = datetime_parser)

    def delete_all_wanderpis(self):
        videos = db.session.query(Wanderpi).filter(Wanderpi.travel_id == self.id).all()
        
        for video in videos:
            video.delete()
            
        db.session.commit()
        return True

    def get_all_wanderpis(self):
        return db.session.query(Wanderpi).filter(Wanderpi.travel_id == self.id).all()

    def delete(self, id):
        if os.path.isdir(self.travel_folder_path):
            print("Removing folder from disk")
            shutil.rmtree(self.travel_folder_path, ignore_errors=True)

        db.session.query(Travel).filter(Travel.id == id).delete()
        db.session.commit()
        return True


    @staticmethod
    def get_by_id(id):
        return db.session.query(Travel).get(id)
    
    @staticmethod
    def get_all():
        return db.session.query(Travel).all()