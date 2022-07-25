# task that accepts an image and returns a face object if a face is detected in the image
# import cv2
import numpy as np
# import os
# import time

from utils.path_manager import PathManager
from background.tasks.base_task import BaseTask
import face_recognition
import time

class FaceTask(BaseTask):
    def __init__(self, known_faces, image, task_id, task_type, task_progress, task_progress_callback, task_callback):
        BaseTask.__init__(self, task_id, task_type, task_progress,task_progress_callback, task_callback)

        self.result = None
        self.task_error = None

        self.known_faces = known_faces
        self.image_to_search_faces = image

    def run(self):
        print("FaceTask started")
        dic = {}

        percentage  = 100 / len(self.known_faces) 

        # get faces in pictures
        unknown_encodings = face_recognition.face_encodings(self.image_to_search_faces)

        for user in self.known_faces:
            print("Searching for user: " + str(user))
            print("Percentage: " + str(percentage))
            print(user.avatar_encoding)

            # check if there is a face in the image
            if len(unknown_encodings) == 0:
                print("No faces found in image so we don't have to search for faces")
                dic[user.id] = False
                self.task_progress += percentage
                self.task_progress_callback(self.task_progress, self)
                continue

            
            result = self.run_task(user.avatar_encoding, unknown_encodings)
            
            self.task_progress += percentage
            self.task_status = "running"
            
            dic[user.id] = result

            time.sleep(0.1)

            self.task_progress_callback(self.task_progress, self)
        
        self.result = dic
        self.complete()

        return

    def run_task(self, face_encoding_file_name,unknown_encodings):
        # load the face encoding from the file
        face_encoding = []
        path = PathManager.get_instance().calculate_path_for_file(face_encoding_file_name, file_type='enconding') 
        
        print(path)
        face_encoding = np.loadtxt(path)        

        unknown_encoding = unknown_encodings[0]

        results = face_recognition.compare_faces([face_encoding], unknown_encoding)

        if results[0]:
            return True
        else:
            return False
        

    def stop(self):
        self.task_status = "stopped"
        return

    def pause(self):
        self.task_status = "paused"
        return

    def resume(self):
        self.task_status = "resumed"
        return

    def cancel(self):
        self.task_status = "cancelled"
        return

    def start(self):
        self.task_status = "started"
        super().start()
        return

    def complete(self):
        self.task_status = "complete"

        if self.result is not None:
            self.task_callback(self.result,self)

        return 