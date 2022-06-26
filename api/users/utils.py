from sqlalchemy.orm import Session

from models import models

import schemas
import uuid
import datetime

def refresh_token_with_user(db: Session, user: models.User, token: str):
    user.token =  token
    db.add(user)
    db.commit()

    return user.token

def refresh_token(db: Session, username: str, token: str):
    user = db.query(models.User).filter(models.User.username == username).first()
    user.token = token

    db.add(user)
    db.commit()

    return user.token

def get_user_with_token(db: Session, token: str, is_login: bool = False):
    dic = db.query(models.User).filter(models.User.username == token).first()
    
    if dic is None or  (dic.token == None and not is_login):
        return None

    return schemas.UserInDB(**dic.__dict__)

def get_user_by_id(db: Session, user_id: str):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_user(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()


def create_user(db: Session, user: schemas.UserCreate, hashed_password: str):
    
    id = str(uuid.uuid4())
    current_date = datetime.datetime.now()

    db_user = models.User(id=id,
                            username=user.username,
                            email=user.email,
                            full_name=user.full_name,
                            hashed_password=hashed_password,
                            disabled=False,
                            creation_date=current_date,
                            avatar_url= 'https://www.gravatar.com/avatar/',
                            token=None)
    
    db_user.save(db)

    return db_user

def delete_user(db: Session, user_id: str):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    db.delete(user)
    db.commit()

    return user

def update_user(db: Session, user: schemas.User, db_user: models.User):
    # update the user with the new data
    db_user.id = user.id
    db_user.username = user.username
    db_user.email = user.email
    db_user.full_name = user.full_name
    db_user.disabled = user.disabled
    db_user.creation_date = user.creation_date

    db.add(db_user)
    db.commit()

    return db_user

def get_items(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()


# def create_stop_item(db: Session, item: schemas.Wanderpi, user_id: int):
#     db_item = models.Item(**item.dict(), owner_id=user_id)
#     db.add(db_item)
#     db.commit()
#     db.refresh(db_item)
#     return db_item