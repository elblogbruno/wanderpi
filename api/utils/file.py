from background.tasks.face_task import FaceTask
from background.tasks.geo_task import GeoTask

import cv2
import random 

class FileUtils:

    @staticmethod
    def on_task_completed():
        print("Task completed")
        return

    # TODO: Extract this method to a separate class
    # TODO: Fix this method to work 
    @staticmethod
    def process_file(file_path, known_faces ):
        print(file_path)
        tasks = []
        
        # get if the file is a video or an image
        # if it is a video, get the first frame
        # if it is an image, get the image
        # if it is neither, skip it
        file_type = 'image'

        if file_path.endswith('.mp4'):
            # get the first frame
            cap = cv2.VideoCapture(file_path)
            ret, frame = cap.read()
            cap.release()
            
            cv2.destroyAllWindows()
            image = frame
            file_type = 'video'

        elif file_path.endswith('.jpg'):
            image = cv2.imread(file_path)
            file_type = 'image'

        geo_task = GeoTask(file_path, file_type, "geo_task" + str(random.randint(50, 100)), "geo_task",  0, FileUtils.on_task_completed)
        face_task = FaceTask(known_faces, file_path, "face_task" + str(random.randint(50, 100)), "face_task",  0, FileUtils.on_task_completed)

        tasks.append(geo_task)
        tasks.append(face_task)

        for task in tasks:
            task.start()
