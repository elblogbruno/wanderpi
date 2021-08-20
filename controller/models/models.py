from werkzeug.security import generate_password_hash, check_password_hash
import db
from sqlalchemy import Column, Boolean, String, Float, DateTime, Text, Date, Time, desc
# from datetime import datetime
import os
import json
import shutil
import uuid
import random
from datetime import *

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
    stop_id  = Column(String(256), nullable=False)
    is_image = Column(Boolean)
    is_360 = Column(Boolean)
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

    def get_all_points(self):
        return db.session.query(Point).filter(Point.file_owner_id == self.id).all()
        
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
    # notes = Column(String(256), nullable=False)
    
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

    def delete_all_stops(self):
        stops = db.session.query(Stop).filter(Stop.travel_id == self.id).all()
        
        for stop in stops:
            stop.delete()
            
        db.session.commit()
        return True

    def delete_all_wanderpis(self):
        videos = db.session.query(Wanderpi).filter(Wanderpi.travel_id == self.id).all()
        
        for video in videos:
            video.delete()
            
        db.session.commit()
        return True

    def get_all_notes(self):
        return db.session.query(Note).filter(Note.travel_id == self.id).all()

    def get_total_price(self):
        total = 0

        notes = self.get_all_notes()
        for note in notes:
            total += note.total_price
        return total

    def get_all_wanderpis(self, filter=None):
        if filter:
            is_image = (filter == 'image')
            return db.session.query(Wanderpi).filter(Wanderpi.travel_id == self.id, Wanderpi.is_image == is_image).all()
        else:
            return db.session.query(Wanderpi).filter(Wanderpi.travel_id == self.id).all()

    def get_all_stops(self):
        return db.session.query(Stop).filter(Stop.travel_id == self.id).all()

    def delete(self):
        if os.path.isdir(self.travel_folder_path):
            print("Removing folder from disk")
            shutil.rmtree(self.travel_folder_path, ignore_errors=True)

        db.session.query(Travel).filter(Travel.id == self.id).delete()
        db.session.commit()
        return True

    def init_calendar(self):
        sdate = self.start_date
        edate = self.end_date
        calendar_days = [sdate+timedelta(days=x) for x in range((edate-sdate).days)]
            
        print(calendar_days)
        if len(calendar_days) == 0:
            calendar_days.append(sdate)

        for day in calendar_days:
            note_id = str(uuid.uuid4())
            note = Note(id=note_id, travel_id=self.id, content="No content", total_price=0.0, day=day)
            note.save()

    @staticmethod
    def get_by_id(id):
        return db.session.query(Travel).get(id)
    
    @staticmethod
    def get_all():
        return db.session.query(Travel).all()

class Point(db.Base):
    __tablename__ = 'points'
    id = Column(String(256), primary_key=True)
    file_owner_id = Column(String(256), nullable=False)
    lat = Column(String(256), nullable=False)
    long = Column(String(256), nullable=False)
    
    def __repr__(self):
        return f'<Point {self.id}>'

    def set_id(self, file_owner_id):
        self.file_owner_id = file_owner_id

    def save(self):
        db.session.add(self)
        db.session.commit()
        #self.save_json()

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}
    # this functions gets the object as a dictionary and saves it to a json file
    def save_json(self):
        #write json file on path where file is located
        json_file_path = self.travel_folder_path + '/{0}-points.json'.format(self.id)

        with open(json_file_path, 'w') as f:
            json.dump(self.as_dict(), f)


    @staticmethod
    def get_by_id(id):
        return db.session.query(Point).get(id)
    
    @staticmethod
    def get_all():
        return db.session.query(Point).all()

class Stop(db.Base):
    __tablename__ = 'stops'
    id = Column(String(256), primary_key=True)
    travel_id = Column(String(256), nullable=False)
    lat = Column(String(256), nullable=False)
    long = Column(String(256), nullable=False)
    name = Column(String(256), nullable=False)


    def __repr__(self):
        return f'<Stop {self.id}>'

    def delete(self, path=None):
        db.session.query(Stop).filter(Stop.id == self.id).delete()
        db.session.commit()
        # if path and os.path.exists(path):
            # os.path.removedir(path)
        return True

    def save(self):
        db.session.add(self)
        db.session.commit()
        #self.save_json()

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

    def get_all_wanderpis(self, filter=None):
        if filter:
            is_image = (filter == 'image')
            return db.session.query(Wanderpi).filter(Wanderpi.stop_id == self.id, Wanderpi.is_image == is_image).all()
        else:
            return db.session.query(Wanderpi).filter(Wanderpi.stop_id == self.id).all()
    
    def get_random_thumbnail(self):
        wanderpis  = self.get_all_wanderpis()
        if len(wanderpis) > 0:
            i = random.randint(0, len(wanderpis)-1)
            return wanderpis[i].file_thumbnail_path
        else:
            return '/static/wanderpi-icon.svg'
    @staticmethod
    def get_by_id(id):
        return db.session.query(Stop).get(id)
    
    @staticmethod
    def get_all():
        return db.session.query(Stop).all()

class Note(db.Base):
    __tablename__ = 'notes'
    id = Column(String(256), primary_key=True)
    travel_id = Column(String(256), nullable=False)
    content = Column(String(256), nullable=False)
    total_price = Column(Float, nullable=False)
    day = Column(Date, nullable=False)
    creation_date = Column(DateTime, nullable=False, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<Note {self.id}>'


    def set_id(self, file_owner_id):
        self.file_owner_id = file_owner_id

    def save(self):
        db.session.add(self)
        db.session.commit()
        #self.save_json()

    def get_all_input(self, filter=None):
        return db.session.query(MoneyInput).filter(MoneyInput.note_id == self.id).all()

    def get_all_input_as_json(self):
        return json.dump(db.session.query(MoneyInput).filter(MoneyInput.note_id == self.id).all(), default= datetime_parser)

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

    @staticmethod
    def get_by_id(id):
        return db.session.query(Note).get(id)
    
    @staticmethod
    def get_all():
        return db.session.query(Note).all()


class MoneyInput(db.Base):
    __tablename__ = 'input'
    id = Column(String(256), primary_key=True)
    note_id = Column(String(256), nullable=False)
    name = Column(String(256), nullable=False)
    hour = Column(Time, nullable=False)
    value = Column(Float, nullable=False)
    
    # def __repr__(self):
    #     return f'<MoneyInput {self.id}>'
    
    def set_id(self, note_id):
        self.note_id = note_id

    def save(self):
        db.session.add(self)
        db.session.commit()
        #self.save_json()

    def as_json(self):
        return {
            "id": self.id,
            "note_id":self.note_id,
            "name": self.name,
            "hour": self.hour.isoformat(),
            "value": self.value
        }    

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

    @staticmethod
    def get_by_id(id):
        return db.session.query(MoneyInput).get(id)
    
    @staticmethod
    def get_all():
        return db.session.query(MoneyInput).all()
    
    @staticmethod
    def delete(id):
        db.session.query(MoneyInput).filter(MoneyInput.id == id).delete()
        db.session.commit()
        return True