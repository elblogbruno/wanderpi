import uuid

from matplotlib.image import thumbnail
from torch import le
from background.tasks.face_task import FaceTask
from background.tasks.geo_task import GeoTask

import cv2
import random 
import os
import schemas
import datetime

import json 

class FileUtils:

    @staticmethod
    def save_file(file_location, file_content):
        file_dir = os.path.dirname(file_location)

        # if file_location does not exist, create it
        if not os.path.exists(file_location):
            if not os.path.exists(file_dir):
                os.makedirs(file_dir, exist_ok=True)

            with open(file_location, "w+") as f:
                f.write(file_content)

            print("File created")
            return True
        else:
            print("File already exists")
            return False

    @staticmethod
    def save_picture(file_location, uploaded_file):
        file_dir = os.path.dirname(file_location)

        # if file_location does not exist, create it
        if not os.path.exists(file_location):
            # if not os.path.exists(file_dir):
            #     os.makedirs(file_dir, exist_ok=True)

            with open(file_location, "wb") as f:
                f.write(uploaded_file.file.read())

            print("File created")
            return True
        else:
            print("File already exists")
            return False

    global tmp_file

    @staticmethod
    def on_task_completed(result, task):
        print("Task completed")
        print(result)
        global tmp_file

        if task.task_type ==  'geo_task':
            res = json.loads(task.result)

            tmp_file.address = res.address
            tmp_file.latitude = res.latitude
            tmp_file.longitude = res.longitude

        elif task.task_type ==  'face_task':
            # users = []
            users = ""
            for face_user_id in task.result.keys():
                detected = task.result[face_user_id]
                if detected:
                    users += face_user_id + "+"
                    # users.add(face_user_id)
            print(users)
            tmp_file.users_detected = users

        return 

    @staticmethod
    def on_task_percentage(percentage, task):
        print("Task " + task.task_id)
        print("Percentage: " + str(percentage))
        return
    
    @staticmethod
    def extract_frame_from_video(video_path, frame_path, frame_number):
        cap = cv2.VideoCapture(video_path)
        cap.set(1, frame_number)
        ret, frame = cap.read()
        cv2.imwrite(frame_path, frame)
        cap.release()
        cv2.destroyAllWindows()
        return frame_path

    # TODO: Extract this method to a separate class
    # TODO: Fix this method to work 
    @staticmethod
    def process_file(file_path, known_faces):
        print(file_path)
        tasks = []
        
        global tmp_file

        id = str(uuid.uuid4()) # we create the file unique id 

        # get if the file is a video or an image
        # if it is a video, get the first frame
        # if it is an image, get the image
        # if it is neither, skip it
        file_type = 'image'
        file_name = os.path.basename(file_path) # we get the name of file with format 
        file_format = file_name.split('.')[1] # TODO: BETTER WAY OF GETTING FILE FORMAT

        if file_format == 'jpg':
            file_format = 'jpeg'

        thumbnail_file_format = file_format

        tmp_file = schemas.Wanderpi(
            id=id,
            name=file_name,
            latitude=0,
            longitude=0,
            address="Unknown",
            user_created_by=None,
            creation_date=datetime.datetime.now(),
            last_update_date=datetime.datetime.now(),
            type = file_type,
            uri = file_path,
            thumbnail_uri = file_path
        )

        image = cv2.imread(file_path)
        
        if image is None:
            file_type = 'video'
            image = FileUtils.extract_frame_from_video(file_path, "tmp.jpeg", 1)
            thumbnail_file_format = 'jpeg'
            
            if len(image) == 0:
                print("Could not read video")
                return

        geo_task = GeoTask(file_path, file_type, "geo_task" + str(random.randint(50, 100)), "geo_task",  0, FileUtils.on_task_percentage, FileUtils.on_task_completed)
        face_task = FaceTask(known_faces, image, "face_task" + str(random.randint(50, 100)), "face_task",  0, FileUtils.on_task_percentage, FileUtils.on_task_completed)

        tmp_file.type = file_type

        uri = f"/file/{file_type}/{str(id)}?format={file_format}" # file_type can be 'video' and 'image' by the moment
        thumbnail_uri = f"/file/image/{str(id)}?format={thumbnail_file_format}&width={500}&height={500}" # thumbnail is always image
 
        tmp_file.uri = uri
        tmp_file.thumbnail_uri = thumbnail_uri

        tasks.append(geo_task)
        tasks.append(face_task)

        for task in tasks:
            task.start()

        return tmp_file

