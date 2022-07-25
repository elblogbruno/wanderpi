from utils.connection_manager import ConnectionManager
from utils.path_manager import PathManager
from utils.db_manager import DbManager
from utils.memory_manager import MemoryManager
from background.upload_watchdog import UploadWatchdog
import uvicorn
from fastapi import Depends, FastAPI, HTTPException, WebSocket, WebSocketDisconnect, status

from models.models import *


import logging
from dependencies import *
from routers import stops, travels, wanderpis, users, auth, file, drives


dir_path = 'wanderpi.log'
logging.basicConfig(filename=dir_path, filemode='w', format='%(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# add the handler to the root logger
logging.getLogger('').addHandler(console)
logging.info("Log file will be saved to temporary path: {0}".format(dir_path))

Base.metadata.create_all(bind=engine)


app = FastAPI(debug = True)
app.include_router(auth.router)
app.include_router(stops.router)
app.include_router(travels.router)
app.include_router(wanderpis.router)
app.include_router(users.router)
app.include_router(file.router)
app.include_router(drives.router)

db_manager = DbManager(db_session=SessionLocal())

config = MemoryManager('./api/config/', 'memory.json', False) # create a singleton instance of MemoryManagement
paths_config = PathManager()
watchdog = UploadWatchdog(config.memories) 

@app.post("/token", response_model=schemas.Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db : Session = Depends(get_db)):
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )

    utils.users.refresh_token(db, user.username, access_token)
    return {"access_token": access_token, "token_type": "bearer"}

manager = ConnectionManager()

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str,  path_str: str , db: Session = Depends(get_db)):
    
    # if (path_to_upload.isNotEmpty)
    # {
    #   _channel = WebSocketChannel.connect(
    #     Uri.parse('wss://${Api.instance.API_BASE_URL}/ws/{$path_to_upload}'),
    #   );
    # }
    
    await manager.connect(websocket)
    
    print("Connected")

    await manager.broadcast(client_id + " connected")
    await manager.broadcast(client_id + " is watchdoging for path " + path_str)

    try:
        while True:
            data = await websocket.receive_text()
            # print('WEBSOCKET: ' + data)
            if len(data) > 0:
                print('WEBSOCKET: ' + data)

                if data == "get_upload_status":
                    # await manager.send_personal_message(f"You wrote: {data}", websocket)
                    upload_status = UploadWatchdog.get_instance().get_watchdog_status(path=path_str)
                    await manager.broadcast(f"Folder {path_str} {upload_status}")
                elif data == "stop_upload":
                    # UploadWatchdog.get_instance().stop_watchdog(path=path_str)
                    await manager.broadcast(f"Folder {path_str} stopped")
                else:
                    # parse data 
                    dic = json.loads(data)

                    if dic["type"] == "get_wanderpis":
                        wanderpis = utils.wanderpis.get_wanderpis(db=db, skip=dic["skip"], limit=dic["limit"])
                        await manager.send_personal_message(message=json.dumps(wanderpis), websocket=websocket)

    except WebSocketDisconnect:
        manager.disconnect(websocket)
        await manager.broadcast(f"Client #{path_str} left the chat")

if __name__ == "__main__":
    uvicorn.run(app, host='127.0.0.1', port=8000, debug=True)