# task that accepts an image and returns a face object if a face is detected in the image
# import cv2
# import numpy as np
# import os
# import time

from background.tasks.base_task import BaseTask
import face_recognition
import time

class FaceTask(BaseTask):
    def __init__(self, known_faces, image, task_id, task_type, task_progress, task_callback):
        BaseTask.__init__(self, task_id, task_type, task_progress, task_callback)

        self.task_result = None
        self.task_error = None

        self.known_faces = known_faces
        self.image_to_search_faces = image

    def run(self):
        print("FaceTask started")
        dic = {}

        percentage  = len(self.known_faces) / 100

        for user in self.known_faces:
            result = self.run_task(user.avatar_encoding)
            
            self.task_progress += percentage
            self.task_status = "running"
            
            dic[user.id] = result

            time.sleep(0.1)
        
        self.task_result = dic
        self.complete()

        return

    def run_task(self, face_encoding_path):
        # load the face encoding from the file
        face_encoding = []

        with open(face_encoding_path, "rb") as file_object:
            face_encoding = file_object.read()

        unknown_encoding = face_recognition.face_encodings(self.image_to_search_faces)[0]

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

        if self.task_result is not None:
            self.task_callback(self.task_result)

        return 