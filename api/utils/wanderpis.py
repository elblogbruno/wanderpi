from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import models

import schemas


def get_wanderpi(db: Session, wanderpi_id: int):
    return db.query(models.Wanderpi).filter(models.Wanderpi.id == wanderpi_id).first()

def get_wanderpis(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Wanderpi).offset(skip).limit(limit).all()



def create_wanderpi(db: Session, wanderpi: schemas.Wanderpi):
    db_wanderpi = models.Wanderpi(**wanderpi.dict())
    
    db_wanderpi.save(db)

    return db_wanderpi

def delete_wanderpi(db: Session, wanderpi_id: int):
    db_wanderpi = get_wanderpi(db, wanderpi_id)
    
    if db_wanderpi:
        db.delete(db_wanderpi)
        db.commit()
        return db_wanderpi
    else:
        raise HTTPException(status_code=404, detail="Wanderpi with id {0} not found".format(str(wanderpi_id)))

def update_wanderpi(db: Session, wanderpi: schemas.Wanderpi, db_wanderpi: models.Wanderpi):
    db_wanderpi.id = wanderpi.id
    db_wanderpi.name = wanderpi.name
    db_wanderpi.latitude = wanderpi.latitude
    db_wanderpi.longitude = wanderpi.longitude
    db_wanderpi.address = wanderpi.address
    db_wanderpi.creation_date = wanderpi.creation_date
    db_wanderpi.last_update_date = wanderpi.last_update_date
    db_wanderpi.date_range_start = wanderpi.date_range_start
    db_wanderpi.date_range_end = wanderpi.date_range_end
    db_wanderpi.description = wanderpi.description
    db_wanderpi.distance = wanderpi.distance
    db_wanderpi.spent_price = wanderpi.spent_price
    db_wanderpi.image_uri = wanderpi.image_uri
    db_wanderpi.thumbnail_uri = wanderpi.thumbnail_uri
    db_wanderpi.thumbnail_uri_small = wanderpi.thumbnail_uri_small
    db_wanderpi.travel_id = wanderpi.travel_id
    db_wanderpi.wanderpis = wanderpi.wanderpis
    
    db_wanderpi.save(db)

    return db_wanderpi

# def create_wanderpi_item(db: Session, item: schemas.Wanderpi, wanderpi_id: int):
#     db_item = models.Item(**item.dict(), owner_id=wanderpi_id)
#     db.add(db_item)
#     db.commit()
#     db.refresh(db_item)
#     return db_item