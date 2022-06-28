from fastapi import APIRouter, Depends, HTTPException

from dependencies import *


import utils.users

router = APIRouter(
    prefix="/token",
    tags=["token"],
)

@router.post("/validate_token", response_model=schemas.Token)
async def  validate_token(token: schemas.Token, db : Session = Depends(get_db)):
    user = get_current_user(token=token, db=db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token is invalid",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return schemas.Token(access_token=token.access_token, token_type=token.token_type)




@router.post("/register", response_model=schemas.UserInDB)
async def register_user(form_data: schemas.UserCreate, db : Session = Depends(get_db)):
    user = utils.users.get_user_with_token(db, form_data.username)
    
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

