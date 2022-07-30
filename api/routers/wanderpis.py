import os
from typing import List

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, WebSocket, WebSocketDisconnect

from background.upload_watchdog import UploadWatchdog
from utils.memory_manager import MemoryManager
from utils.path_manager import PathManager

from dependencies import *
from fastapi.responses import PlainTextResponse

import utils.wanderpis
import utils.stops

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

    return  utils.wanderpis.create_wanderpi(db=db, wanderpi=wanderpi, current_user=current_user, stop_id=wanderpi.stop_id)

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

@router.get("/bulk_upload/{drive_id}", response_class=PlainTextResponse)
async def create_upload_file(drive_id: str, stop_id: str , db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):

    # create a random folder for current user to upload  files to
    
    # the folder will be created at the drive choosed by user at Flutter and at the stop the user is currently inside

    # current_drive = MemoryManager('./api/config/', 'memory.json', False).get_drive(drive_id=drive_id)
    current_drive = MemoryManager.get_instance().get_drive(drive_id=drive_id)

    # create a random folder inside current_drive

    current_stop = utils.stops.get_stop(db = db, stop_id=stop_id)

    # example c:/wanderpi/stockhollm/2020_34_02 

    # current datetime in format 2020_34_02
    current_datetime = datetime.now().strftime("%Y_%m_%d")

    random_folder = os.path.join(current_drive.memory_access_uri, current_stop.name , current_datetime)

    if not os.path.exists(random_folder):
        os.makedirs(random_folder)

    UploadWatchdog.get_instance().add_new_path_to_watch(path=random_folder, stop_id=stop_id)

    set_local_current_user(current_user)

    # return HttpResponse(status=200 , content=random_folder)
    
    # remove "" from random_folder
    return random_folder




# manager = ConnectionManager()


