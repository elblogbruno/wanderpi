from fastapi import APIRouter, Depends, HTTPException

from dependencies import *

import utils.wanderpis

router = APIRouter(
    prefix="/wanderpis",
    tags=["wanderpis"],
    dependencies=[Depends(get_db), Depends(get_current_active_user)],
    responses={404: {"description": "Not found"}},
)

@router.get("/", response_model=list[schemas.Wanderpi])
def read_wanderpis(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    wanderpis_list = utils.wanderpis.get_wanderpis(db, skip=skip, limit=limit)
    return wanderpis_list

@router.post("/", response_model=schemas.Wanderpi)
def create_wanderpi(wanderpi: schemas.Wanderpi, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_user = utils.wanderpis.get_wanderpi(db=db, wanderpi_id=wanderpi.id)
    if db_user:
        raise HTTPException(status_code=400, detail="Wanderpi already created")

    return  utils.wanderpis.create_wanderpi(db=db, wanderpi=wanderpi)

@router.put("/{id}", response_model=schemas.Wanderpi)
def update_wanderpi(wanderpi: schemas.Wanderpi, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_wanderpi = utils.wanderpis.get_wanderpi(db=db, wanderpi_id=wanderpi.id)

    if not db_wanderpi:
        raise HTTPException(status_code=404, detail="Wanderpi with id {0} not found".format(str(id)))

    return  utils.wanderpis.update_wanderpi(db=db, wanderpi=wanderpi, db_wanderpi = db_wanderpi)

@router.delete("/{id}", response_model=schemas.Wanderpi)
def delete_wanderpi(id: str, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_wanderpi = utils.wanderpis.get_wanderpi(db=db, wanderpi_id=id)

    if not db_wanderpi:
        raise HTTPException(status_code=404, detail="Wanderpi with id {0} not found".format(str(id)))

    return  utils.wanderpis.delete_wanderpi(db=db, wanderpi_id=id)

