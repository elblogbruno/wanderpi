from fastapi import APIRouter, Depends, HTTPException
from utils.image_editor import ImageEditor
from utils.path_manager import PathManager
import utils.users
from dependencies import *

from starlette.responses import StreamingResponse
from PIL import Image, ImageShow

router = APIRouter(
    prefix="/users",
    tags=["users"],
    dependencies=[Depends(get_db), Depends(get_current_active_user)],
    responses={404: {"description": "Not found"}},
)

@router.get("/id/{user_id}", response_model=schemas.User)
async def get_user(user_id: str, db : Session = Depends(get_db)):
    user = utils.users.get_user_by_id(db, user_id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.delete("/{id}", response_model=schemas.User)
def delete_user(id: int, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_wanderpi = utils.wanderpis.get_wanderpi(db=db, wanderpi_id=id)

    if not db_wanderpi:
        raise HTTPException(status_code=404, detail="Wanderpi with id {0} not found".format(str(id)))

    return  utils.wanderpis.delete_wanderpi(db=db, wanderpi_id=id)

@router.get("/me", response_model=schemas.User)
async def read_users_me(current_user: schemas.User = Depends(get_current_active_user)):
    return current_user
