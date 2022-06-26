import uvicorn
from typing import  Union

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

from db import SessionLocal, engine

from sqlalchemy.orm import Session

from models.models import *

import schemas

import wanderpis.utils
import travels.utils
import stops.utils
import users.utils

import logging

from jose import JWTError, jwt
from passlib.context import CryptContext

# to get a string like this run:
# openssl rand -hex 32
SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

dir_path = 'wanderpi.log'
logging.basicConfig(filename=dir_path, filemode='w', format='%(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# add the handler to the root logger
logging.getLogger('').addHandler(console)
logging.info("Log file will be saved to temporary path: {0}".format(dir_path))

Base.metadata.create_all(bind=engine)

app = FastAPI()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def authenticate_user(db, username: str, password: str):
    user = users.utils.get_user_with_token(db, username, is_login=True)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def create_access_token(data: dict, expires_delta: Union[timedelta, None] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme), db : Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = schemas.TokenData(username=username)
    except JWTError:
        raise credentials_exception

    user = users.utils.get_user_with_token(db, token=token_data.username)
    if user is None:
        print("User not found")
        raise credentials_exception
    return user

async def get_current_active_user(current_user: schemas.User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

@app.post("/validate_token", response_model=schemas.Token)
def validate_token(token: str = Depends(oauth2_scheme), db : Session = Depends(get_db)):
    user = get_current_user(token=token, db=db)
    return schemas.Token(token=token)

@app.post("/token", response_model=schemas.Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db : Session = Depends(get_db)):
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    users.utils.refresh_token(db, user.username, access_token)
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/register", response_model=schemas.UserInDB)
async def register_user(form_data: schemas.UserCreate, db : Session = Depends(get_db)):
    user = users.utils.get_user_with_token(db, form_data.username)
    
    if user:
        raise HTTPException(status_code=400, detail="User already exists")

    hashed_password = get_password_hash(form_data.password)
    user = users.utils.create_user(db, form_data, hashed_password)
    
    return user

@app.post("/token/logout", response_model=schemas.Token)
async def logout_user(current_user: schemas.User = Depends(get_current_active_user), db : Session = Depends(get_db)):
    user = users.utils.get_user(db, current_user.username)
    if not user:
        raise HTTPException(status_code=400, detail="User does not exist")
    
    users.utils.refresh_token_with_user(db, user, None)
    return user

@app.post("/token/refresh", response_model=schemas.Token)
async def refresh_token(current_user: schemas.User = Depends(get_current_active_user), db : Session = Depends(get_db)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": current_user.username}, expires_delta=access_token_expires
    )

    users.utils.refresh_token(db, current_user.username, access_token)

    return {"access_token": access_token, "token_type": "bearer"}


@app.get("/users/{user_id}", response_model=schemas.User)
async def get_user(user_id: str, db : Session = Depends(get_db)):
    user = users.utils.get_user_by_id(db, user_id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.get("/users/me", response_model=schemas.User)
async def read_users_me(current_user: schemas.User = Depends(get_current_active_user)):
    return current_user

@app.post("/travels/", response_model=schemas.Travel)
def create_travel(travel: schemas.Travel, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_travel = travels.utils.get_travel(db=db, travel_id=travel.id)
    if db_travel:
        raise HTTPException(status_code=400, detail="Travel already created")

    return  travels.utils.create_travel(db=db, travel=travel, current_user=current_user)

@app.put("/travels/{id}", response_model=schemas.Travel)
def update_travel(travel: schemas.Travel, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_travel = travels.utils.get_travel(db=db, travel_id=travel.id)

    if not db_travel:
        raise HTTPException(status_code=404, detail="Travel with id {0} not found".format(str(id)))

    return  travels.utils.update_travel(db=db, travel=travel, db_travel = db_travel)

@app.delete("/travels/{id}")
def delete_travel(id: str, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    print(id)

    db_travel = travels.utils.get_travel(db=db, travel_id=id)

    if not db_travel:
        raise HTTPException(status_code=404, detail="Travel with id {0} not found".format(str(id)))

    return  travels.utils.delete_travel(db=db, travel_id=str(id))

@app.get("/travels/", response_model=list[schemas.Travel])
def read_travel(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    travels_list = travels.utils.get_travels(db, skip=skip, limit=limit)
    return travels_list




@app.post("/stops/", response_model=schemas.Stop)
def create_stop(stop: schemas.Stop, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_user = stops.utils.get_stop(db=db, stop_id=stop.id)
    if db_user:
        raise HTTPException(status_code=400, detail="Stop already created")

    return  stops.utils.create_stop(db=db, stop=stop)

@app.put("/stops/{id}", response_model=schemas.Stop)
def update_stop(stop: schemas.Stop, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_stop = stops.utils.get_stop(db=db, stop_id=stop.id)

    if not db_stop:
        raise HTTPException(status_code=404, detail="Stop with id {0} not found".format(str(id)))


    return  stops.utils.update_stop(db=db, stop=stop, db_stop = db_stop)

@app.get("/stops/", response_model=list[schemas.Stop])
def read_stops(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    stops_list = stops.utils.get_stops(db, skip=skip, limit=limit)
    return stops_list



@app.post("/wanderpis/", response_model=schemas.Wanderpi)
def create_wanderpi(wanderpi: schemas.Wanderpi, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_user = wanderpis.utils.get_wanderpi(db=db, wanderpi_id=wanderpi.id)
    if db_user:
        raise HTTPException(status_code=400, detail="Wanderpi already created")

    return  wanderpis.utils.create_wanderpi(db=db, wanderpi=wanderpi)

@app.put("/wanderpis/{id}", response_model=schemas.Wanderpi)
def update_wanderpi(wanderpi: schemas.Wanderpi, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_wanderpi = wanderpis.utils.get_wanderpi(db=db, wanderpi_id=wanderpi.id)

    if not db_wanderpi:
        raise HTTPException(status_code=404, detail="Wanderpi with id {0} not found".format(str(id)))

    return  wanderpis.utils.update_wanderpi(db=db, wanderpi=wanderpi, db_wanderpi = db_wanderpi)

@app.get("/wanderpis/", response_model=list[schemas.Wanderpi])
def read_wanderpis(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    wanderpis_list = wanderpis.utils.get_wanderpis(db, skip=skip, limit=limit)
    return wanderpis_list

if __name__ == "__main__":
    uvicorn.run(app, host='127.0.0.1', port=8000, debug=True)