from sqlalchemy.orm import Session

from models import models

import schemas
import uuid
import datetime

def get_travel(db: Session, travel_id: int):
    return db.query(models.Travel).filter(models.Travel.id == travel_id).first()

def get_travels(db: Session, skip: int = 0, limit: int = 100):

    # convert the users to a list of schemas.User
    
    return db.query(models.Travel).offset(skip).limit(limit).all()


def create_travel(db: Session, travel: schemas.Travel, current_user: schemas.User):
    
    id = str(uuid.uuid4())
    current_date = datetime.datetime.now()

    db_travel = models.Travel(
        id = id,
        
        name = travel.name,
        latitude = travel.latitude,
        longitude = travel.longitude,
        address = travel.address,
        
        creation_date = current_date,
        last_update_date = current_date,

        date_range_start = travel.date_range_start,
        date_range_end = travel.date_range_end,
        description = travel.description,

        distance = 0,
        spent_price = 0, 
        user_created_by = current_user.id
    )
    
    db_travel.save(db)

    travel = schemas.Travel(
        id = id,
        name = travel.name,
        latitude = travel.latitude,
        longitude = travel.longitude,
        address = travel.address,
        creation_date = current_date,
        last_update_date = current_date,
        date_range_start = travel.date_range_start,
        date_range_end = travel.date_range_end,
        description = travel.description,
        distance = 0,
        spent_price = 0, 
        user_created_by = current_user,
        stops=[],
        documents= [],
    )

    print(travel)

    return travel

def delete_travel(db: Session, travel_id: str):
    travel = db.query(models.Travel).filter(models.Travel.id == travel_id).first()
    db.delete(travel)
    db.commit()

    return travel

def update_travel(db: Session, travel: schemas.Travel, db_travel: models.Travel):
    # update the travel with the new data
    db_travel.id = travel.id
    db_travel.name = travel.name
    db_travel.latitude = travel.latitude
    db_travel.longitude = travel.longitude
    db_travel.address = travel.address
    db_travel.creation_date = travel.creation_date
    db_travel.last_update_date = travel.last_update_date
    db_travel.date_range_start = travel.date_range_start
    db_travel.date_range_end = travel.date_range_end
    db_travel.description = travel.description
    db_travel.distance = travel.distance
    db_travel.spent_price = travel.spent_price

    db.add(db_travel)
    db.commit()

    return db_travel

def get_items(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Travel).offset(skip).limit(limit).all()


# def create_stop_item(db: Session, item: schemas.Wanderpi, travel_id: int):
#     db_item = models.Item(**item.dict(), owner_id=travel_id)
#     db.add(db_item)
#     db.commit()
#     db.refresh(db_item)
#     return db_item