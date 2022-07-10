from ast import Str
from faulthandler import disable
from lib2to3.pgen2 import token
from sqlalchemy.sql.schema import ForeignKey
import db
from sqlalchemy import Column, Boolean, String, Float, DateTime, Text, Date, Time, asc, func
from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy.orm import relationship

from typing import List
from pydantic import BaseModel
from db import Base

import os
import json
import shutil
import uuid
import random
from datetime import *

def datetime_parser(o):
    if isinstance(o, datetime):
        return o.__str__()

class BaseModelSchema(object):
    @declared_attr
    def __tablename__(cls):
        return cls.__name__.lower()


    id = Column(String(36), primary_key=True)
    name = Column(String(255))
    latitude = Column(Float)
    longitude = Column(Float)
    address = Column(String(255))
    creation_date = Column(DateTime, default=datetime.now)
    last_update_date = Column(DateTime, default=datetime.now)
    # it is a User pydantic class 
    user_created_by = Column(String(255))
    # user_created_by =  relationship("User", back_populates="travels")

    def save(self, db):
        db.add(self)
        db.commit()
        db.refresh(self)
        return self


class User(Base):
    __tablename__ = 'users'
    id = Column(String(36), primary_key=True)
    username = Column(String(255))
    email = Column(String(255))
    full_name = Column(String(255))
    hashed_password = Column(String(255))
    avatar_url = Column(String(255))
    avatar_encoding = Column(String(255))
    disabled = Column(Boolean, default=False)
    creation_date = Column(DateTime, default=datetime.now)
    token = Column(String(255))
    # children = relationship("Child")

    def save(self, db):
        db.add(self)
        db.commit()
        db.refresh(self)
        return self

    def __repr__(self):
        return f"<User {self.username}>"

class Travel(Base, BaseModelSchema):
    __tablename__ = 'travels'
    date_range_start = Column(DateTime)
    date_range_end = Column(DateTime)
    description = Column(String)
    distance = Column(Float) 
    spent_price = Column(Float)
    
    # list of documents, travels 
    stops = relationship("Stop")
    documents = relationship("Document")
   
   

class Stop(Base, BaseModelSchema):
    __tablename__ = 'stops'
    date_range_start = Column(DateTime)
    date_range_end = Column(DateTime)
    description = Column(String)
    distance = Column(Float) 
    spent_price = Column(Float)

    image_uri = Column(String)
    thumbnail_uri = Column(String) 
    thumbnail_uri_small = Column(String) 

    travel_id = Column(String(36), ForeignKey("travels.id"))

    # list of documents, travels 
    wanderpis = relationship("Wanderpi")

class Document(Base, BaseModelSchema):
    __tablename__ = 'documents'
    image_uri = Column(String)
    thumbnail_uri = Column(String)
    type = Column(String)
    description = Column(String)

    travel_id = Column(String(36), ForeignKey("travels.id"))

class Wanderpi(Base, BaseModelSchema):
    __tablename__ = 'wanderpis'
    type = Column(String)
    uri = Column(String)
    thumbnail_uri = Column(String)
    stop_id = Column(String(36), ForeignKey("stops.id"))
