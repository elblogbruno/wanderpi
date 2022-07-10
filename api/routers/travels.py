from fastapi import APIRouter, Depends, HTTPException
import utils.travels

from dependencies import *

router = APIRouter(
    prefix="/travels",
    tags=["travels"],
    dependencies=[Depends(get_db), Depends(get_current_active_user)],
    responses={404: {"description": "Not found"}},
)



@router.post("/", response_model=schemas.Travel)
def create_travel(travel: schemas.Travel, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_travel = utils.travels.get_travel(db=db, travel_id=travel.id)
    if db_travel:
        raise HTTPException(status_code=400, detail="Travel already created")

    return  utils.travels.create_travel(db=db, travel=travel, current_user=current_user)

@router.put("/{id}", response_model=schemas.Travel)
def update_travel(travel: schemas.Travel, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_travel = utils.travels.get_travel(db=db, travel_id=travel.id)

    if not db_travel:
        raise HTTPException(status_code=404, detail="Travel with id {0} not found".format(str(id)))

    return  utils.travels.update_travel(db=db, travel=travel, db_travel = db_travel)

@router.delete("/{id}")
def delete_travel(id: str, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    print(id)

    db_travel = utils.travels.get_travel(db=db, travel_id=id)

    if not db_travel:
        raise HTTPException(status_code=404, detail="Travel with id {0} not found".format(str(id)))

    return  utils.travels.delete_travel(db=db, travel_id=str(id))

@router.get("/", response_model=list[schemas.Travel])
def read_travel(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    travels_list = utils.travels.get_travels(db, skip=skip, limit=limit)
    return travels_list

@router.get("/{id}/stops", response_model=list[schemas.Stop])
def read_travel_stops(id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    stops_list = utils.travels.get_travel_stops(db, id, skip=skip, limit=limit)
    return stops_list