# from fastapi import FileResponse
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from utils.path_manager import PathManager
from utils.image_editor import ImageEditor
from dependencies import *
import io
from starlette.responses import StreamingResponse
from PIL import Image, ImageShow
import os

router = APIRouter(
    prefix="/file",
    tags=["file"],
)

# When getting an image from server we call this endpoint
# Example : profile picture or saved picture
@router.get("/image/{file_id}")
async def get_image(file_id: str, format: str = 'jpeg', height: int = 0, width: int = 0):
    if format != 'jpeg' and format != 'png':
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only JPG and PNG files are allowed",
        )
    
    file_t = 'png'  if format == 'png' else 'jpeg'

    file_name = f"{file_id}.{file_t}"

    file_location =  PathManager.get_instance().calculate_path_for_file(file_name)

    print(file_location)

    if not os.path.exists(file_location):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="File not found",
        )
    
    img_png = Image.open(file_location)

    if height != 0 and width != 0:
        img_png = ImageEditor.resize_image(file_location, height, width)

    filtered_image = io.BytesIO()
    img_png.save(filtered_image,  format=file_t.capitalize())
    filtered_image.seek(0)

    return StreamingResponse(filtered_image, media_type=f"image/{file_t}")


@router.get("/video/{file_id}")
async def get_video(file_id: str, format: str = 'jpeg', height: int = 0, width: int = 0):
    file_name = f"{file_id}.{format}"

    file_location =  PathManager.get_instance().calculate_path_for_file(file_name)

    print(file_location)

    if height == 0 and width == 0:
        img_png = Image.open(file_location)

        return StreamingResponse(io.BytesIO(img_png.tobytes()), media_type=f"image/{format}")
    else:
        im_png = ImageEditor.resize_image(file_location, height, width)
        # ImageShow.show(im_png)
        return StreamingResponse(io.BytesIO(im_png.tobytes()), media_type=f"image/{format}")



