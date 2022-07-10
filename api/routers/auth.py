from tempfile import SpooledTemporaryFile
import uuid
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File

import face_recognition
from dependencies import *

import os
import shutil
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

def save_file(file_location, file_content):
    file_dir = os.path.dirname(file_location)

    # if file_location does not exist, create it
    if not os.path.exists(file_location):
        if not os.path.exists(file_dir):
            os.makedirs(file_dir, exist_ok=True)

        with open(file_location, "wb") as f:
            f.write(file_content)

        print("File created")
        return True
    else:
        print("File already exists")
        return False

def save_picture(file_location, uploaded_file):
    file_dir = os.path.dirname(file_location)

    # if file_location does not exist, create it
    if not os.path.exists(file_location):
        if not os.path.exists(file_dir):
            os.makedirs(file_dir, exist_ok=True)

        with open(file_location, "wb") as f:
            f.write(uploaded_file.file.read())

        print("File created")
        return True
    else:
        print("File already exists")
        return False

# ONLY ALLOW PNG FILES TO BE UPLOADED FOR NOW
# IMPORTANT: first we register user and then we get the user id to upload the file

@router.post("/upload_profile_picture/{user_id}", response_model=schemas.UserInDB)
async def create_upload_file(user_id: str, db: Session = Depends(get_db), uploaded_file: UploadFile = File(...)):    
    # check if uploaded file is a png file
    if uploaded_file.content_type != "image/png":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PNG files are allowed",
        )

    
    file_location =  os.path.join(os.getcwd(), "api", "files",  uploaded_file.filename)

    created = save_picture(file_location, uploaded_file)

    if not created:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="There was an error creating the file",
        )

    new_file_location = file_location.replace(uploaded_file.filename, f"{user_id}.png")
 
    # # if new_file_location does exists delete it
    # if os.path.exists(new_file_location):
    #     os.remove(new_file_location)

    # if new_file_location does exists, move it to a temporary location
    tmp_file_location = ""

    if os.path.exists(new_file_location):
        tmp_file_location = os.path.join(os.getcwd(), "api", "files", f"{user_id}_{uuid.uuid4()}.png")
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
    encoding_location = os.path.join(os.getcwd(), "api", "encodings", f"{user_id}.txt") 

    # save the encoding to a .txt file
    save_file(encoding_location, face_encoding.tobytes())

    image_uri = '/file/image/' + str(user_id)
    # thumbnail_uri='/file/image/' + str(user_id) + '?height=100&width=100',
        
    user = utils.users.get_user_by_id(db, user_id=user_id, return_db_user=True)
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

