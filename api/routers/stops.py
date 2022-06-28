from fastapi import APIRouter, Depends, HTTPException
from dependencies import *
import utils.stops 

router = APIRouter(
    prefix="/stops",
    tags=["stops"],
    dependencies=[Depends(get_db), Depends(get_current_active_user)],
    responses={404: {"description": "Not found"}},
)

@router.get("/", response_model=list[schemas.Stop])
def read_stops(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    stops_list = utils.stops.get_stops(db, skip=skip, limit=limit)
    return stops_list


@router.post("/", response_model=schemas.Stop)
def create_stop(stop: schemas.Stop, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_user = utils.stops.get_stop(db=db, stop_id=stop.id)
    if db_user:
        raise HTTPException(status_code=400, detail="Stop already created")

    return  utils.stops.create_stop(db=db, stop=stop)

@router.delete("/{id}", response_model=schemas.Stop)
def delete_stop(id: int, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_stop = utils.stops.get_stop(db=db, stop_id=id)

    if not db_stop:
        raise HTTPException(status_code=404, detail="Stop with id {0} not found".format(str(id)))

    return  utils.stops.delete_stop(db=db, stop_id=id)

@router.put("/{id}", response_model=schemas.Stop)
def update_stop(stop: schemas.Stop, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_stop = utils.stops.get_stop(db=db, stop_id=stop.id)

    if not db_stop:
        raise HTTPException(status_code=404, detail="Stop with id {0} not found".format(str(id)))


    return  utils.stops.update_stop(db=db, stop=stop, db_stop = db_stop)


