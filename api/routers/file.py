from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from utils.image_editor import ImageEditor
from dependencies import *
import io
from starlette.responses import StreamingResponse


router = APIRouter(
    prefix="/file",
    tags=["file"],
)

@router.get("/image/{file_id}", response_model=str)
async def get_file(file_id: str, height: int = 0, width: int = 0):
    file_location = f"files/{file_id}"
    
    if height == 0 and width == 0:
        return file_location
    else:
        im_png = ImageEditor.resize_image(file_location, height, width)
        return StreamingResponse(io.BytesIO(im_png.tobytes()), media_type="image/png")


