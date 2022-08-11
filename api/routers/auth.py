import uuid
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Request

import face_recognition

from utils.file import FileUtils
from utils.path_manager import PathManager

from dependencies import *

import os
import numpy as np
import utils.users



router = APIRouter(
    prefix="/token",
    tags=["token"],
)

@router.post("/validate_token", response_model=schemas.UserInDB)
async def  validate_token(token: schemas.Token, db : Session = Depends(get_db)):
    user = utils.users.get_user_by_token(db, token=token.access_token)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token is invalid",
            headers={"WWW-Authenticate": "Bearer"},
        )

    print("User found")
    print(user)
    
    return  user


# ONLY ALLOW PNG and JPG FILES TO BE UPLOADED FOR NOW
# IMPORTANT: first we register user and then we get the user id to upload the file

@router.post("/upload_profile_picture", response_model=schemas.UserInDB)
async def create_upload_file(request: Request, db: Session = Depends(get_db), uploaded_file: UploadFile = File(...)):    
    # get user_id from request fields 
    user_id = request.headers.get("user_id")

    print("Searching for user {}".format(user_id))

    user = utils.users.get_user_by_id(db, user_id=user_id, return_db_user=True)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with id {} not found".format(user_id),
        )
    
    # check if uploaded file is a png file
    if uploaded_file.content_type != "image/png" and uploaded_file.content_type != "image/jpeg":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PNG and JPG files are allowed",
        )
    

    file_location =  PathManager.get_instance().calculate_path_for_file(uploaded_file.filename)

    created = FileUtils.save_picture(file_location, uploaded_file)

    if not created:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="There was an error creating the file",
        )

    file_format = uploaded_file.content_type.split('/')[1] 

    new_file_location = file_location.replace(uploaded_file.filename, f"{user_id}.{file_format}" )
 
    # # if new_file_location does exists delete it
    # if os.path.exists(new_file_location):
    #     os.remove(new_file_location)

    # if new_file_location does exists, move it to a temporary location
    tmp_file_location = ""

    if os.path.exists(new_file_location):
        tmp_file_location = PathManager.get_instance().calculate_path_for_file(f"{user_id}_{uuid.uuid4()}.{file_format}")
        os.rename(new_file_location, tmp_file_location)

    # rename uploaded file to user_id.png
    os.rename(file_location, new_file_location)

    known_image = face_recognition.load_image_file(new_file_location)

    # get the face encodings for the known image
    face_encodings = face_recognition.face_encodings(known_image)

    # check if there is a face in the image
    if len(face_encodings) == 0:

        # if there is no face in the image, delete the file
        os.remove(new_file_location)

        # if there is a temporary file, move it to the original location
        if tmp_file_location != "":
            os.rename(tmp_file_location, new_file_location)

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No face found in the image",
        )
    
    # img send by user is correct so we delete the last file 
    if tmp_file_location != "":
        os.remove(tmp_file_location)

    face_encoding = face_encodings[0] # get the first face encoding

    # encodings are saved in a encodings folder
    encoding_location = PathManager.get_instance().calculate_path_for_file(f"{user_id}.txt", file_type='enconding') 

    # if new_file_location does exists, move it to a temporary location
    tmp_enc_file_location = ""

    if os.path.exists(encoding_location):
        tmp_enc_file_location = PathManager.get_instance().calculate_path_for_file(f"{user_id}_tmp.txt", file_type='enconding') 
        os.rename(encoding_location, tmp_enc_file_location)
    

    # save the encoding to a .txt file
    # save_file(encoding_location, face_encoding)
    np.savetxt(encoding_location, face_encoding)

    # img send by user is correct so we delete the last file 
    if tmp_enc_file_location != "":
        os.remove(tmp_enc_file_location)

    image_uri = f'/file/image/{str(user_id)}?format={file_format}'
    # thumbnail_uri='/file/image/' + str(user_id) + '?height=100&width=100',

    user.avatar_url = image_uri
    user.avatar_encoding = os.path.basename(encoding_location)
    user.save(db)

    return user

@router.post("/register", response_model=schemas.UserInDB)
async def register_user(form_data: schemas.UserCreate, db : Session = Depends(get_db)):
    user = utils.users.get_user_by_username(db, form_data.username)
    
    if user:
        raise HTTPException(status_code=400, detail="User already exists")

    hashed_password = get_password_hash(form_data.password)
    user = utils.users.create_user(db, form_data, hashed_password)
    
    return user

@router.post("/logout", response_model=schemas.Token)
async def logout_user(current_user: schemas.User = Depends(get_current_active_user), db : Session = Depends(get_db)):
    user = utils.users.get_user(db, current_user.username)
    if not user:
        raise HTTPException(status_code=400, detail="User does not exist")
    
    utils.users.refresh_token_with_user(db, user, None)
    return user

@router.post("/refresh", response_model=schemas.Token)
async def refresh_token(current_user: schemas.User = Depends(get_current_active_user), db : Session = Depends(get_db)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": current_user.username}, expires_delta=access_token_expires
    )

    utils.users.refresh_token(db, current_user.username, access_token)

    return {"access_token": access_token, "token_type": "bearer"}

