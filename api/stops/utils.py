from sqlalchemy.orm import Session

from models import models

import schemas


def get_stop(db: Session, stop_id: int):
    return db.query(models.Stop).filter(models.Stop.id == stop_id).first()

def get_stops(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Stop).offset(skip).limit(limit).all()

def update_stop(db: Session, stop: schemas.Stop,  db_stop: models.Stop):
    # update the stop with the new data

    db_stop.id = stop.id
    db_stop.name = stop.name
    db_stop.latitude = stop.latitude
    db_stop.longitude = stop.longitude
    db_stop.address = stop.address
    db_stop.creation_date = stop.creation_date
    db_stop.last_update_date = stop.last_update_date
    db_stop.date_range_start = stop.date_range_start
    db_stop.date_range_end = stop.date_range_end
    db_stop.description = stop.description
    db_stop.distance = stop.distance
    db_stop.spent_price = stop.spent_price
    db_stop.image_uri = stop.image_uri
    db_stop.thumbnail_uri = stop.thumbnail_uri
    db_stop.thumbnail_uri_small = stop.thumbnail_uri_small
    db_stop.travel_id = stop.travel_id
    db_stop.wanderpis = stop.wanderpis


    db.add(db_stop)
    db.commit()

    return db_stop

def create_stop(db: Session, stop: schemas.Stop):
    db_stop = models.Stop(
        id = stop.id,
        name = stop.name,
        latitude = stop.latitude,
        longitude = stop.longitude,
        address = stop.address,
        creation_date = stop.creation_date,
        last_update_date = stop.last_update_date,
        date_range_start = stop.date_range_start,
        date_range_end = stop.date_range_end,
        description = stop.description,
        distance = stop.distance,
        spent_price = stop.spent_price,
        image_uri = stop.image_uri,
        thumbnail_uri = stop.thumbnail_uri,
        thumbnail_uri_small = stop.thumbnail_uri_small,
        travel_id = stop.travel_id,
        wanderpis = stop.wanderpis
    )
    
    db_stop.save(db)

    return db_stop


def get_items(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Stop).offset(skip).limit(limit).all()


# def create_stop_item(db: Session, item: schemas.Wanderpi, stop_id: int):
#     db_item = models.Item(**item.dict(), owner_id=stop_id)
#     db.add(db_item)
#     db.commit()
#     db.refresh(db_item)
#     return db_item