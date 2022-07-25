from typing import List
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from utils.memory_manager import MemoryManager
from utils.image_editor import ImageEditor
from dependencies import *
import io
from starlette.responses import StreamingResponse


router = APIRouter(
    prefix="/drives",
    tags=["drives"],
)

@router.get("{drive_id}", response_model=schemas.MemoryDrive)
async def get_drive(drive_id: str, current_user: schemas.User = Depends(get_current_active_user)):
    return MemoryManager.get_instance().get_drive(drive_id) 

@router.post("/", response_model=schemas.MemoryDrive)
async def create_drive(drive_name: str, db : Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    return MemoryManager.get_instance().create_drive(drive_name)

@router.delete("/{drive_id}", response_model=schemas.MemoryDrive)
async def delete_drive(drive_id: str, db : Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    return MemoryManager.get_instance().delete_drive(drive_id)

@router.get("/", response_model=List[schemas.MemoryDrive])
async def get_drives(db : Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    return MemoryManager.get_instance().get_drives()