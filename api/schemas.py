from typing import List, Union

from pydantic import BaseModel

import datetime

from torch import memory_format

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Union[str, None] = None

class User(BaseModel):
    id: str
    username: str
    email: str
    full_name: str
    avatar_url: str
    disabled: bool 

class UserCreate(BaseModel):
    username: str
    email: str
    full_name: str
    password: str

class UserInDB(User):
    id: str
    avatar_encoding: str
    hashed_password: str
    creation_date: datetime.datetime
    token:  Union[str, None] = None

    class Config:
        orm_mode = True

class BaseSchema(BaseModel):
    """Base schema for all schemas"""
    id: str
    name: str
    latitude: float
    longitude: float
    address: str
    creation_date: datetime.datetime
    last_update_date: datetime.datetime
    user_created_by: Union[str, None] = None 

class Wanderpi(BaseSchema):
    type: str
    uri: str
    thumbnail_uri: str

    class Config:
        orm_mode = True

class Stop(BaseSchema):
    date_range_start : datetime.datetime
    date_range_end : datetime.datetime
    description : str
    distance : float
    spent_price : float

    thumbnail_uri : str
    thumbnail_uri_small : str
    image_uri : str
    travel_id: str

    wanderpis: List[Wanderpi] = []

    class Config:
        orm_mode = True

class Document(BaseSchema):
    image_uri : str
    thumbnail_uri : str
    type: str
    description: str
    travel_id: str

    class Config:
        orm_mode = True

class Travel(BaseSchema):
    date_range_start : datetime.datetime
    date_range_end : datetime.datetime
    description : str
    distance: float
    spent_price : float
    
    stops: List[Stop] = []
    documents: List[Document] = []

    class Config:
        orm_mode = True

class MemoryDrive(BaseModel):
    memory_type : str
    memory_access_uri : str
    memory_id : str