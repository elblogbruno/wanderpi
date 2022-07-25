# task that reads file metadata like geolocation and stores it in the database

from background.tasks.base_task import BaseTask 
import time

class GeoTask(BaseTask):
    def __init__(self, file_path, file_type, task_id, task_type, task_progress, task_progress_callback,  task_callback):
        BaseTask.__init__(self, task_id,  task_type, task_progress, task_progress_callback, task_callback) 

        self.file_path = file_path
        self.file_type = file_type
    
    def run(self):
        print("GeoTask started")
        self.task_status = "running"

        result = self.run_task(self.file_path, self.file_type)

        self.result = result
        self.complete()

        return

    def run_task(self, file_path, file_type):
        self.task_status = "running"
        # reads metadata from picture and gets geolocation
        percentage  = 0.5 

        # get geolocation
        dic = {}

        dic['address'] = 'address'
        dic['latitude'] = 0.0
        dic['longitude'] =  0.0

        self.task_progress += percentage
        self.task_progress_callback(self.task_progress, self)

        return dic




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
            self.task_callback(self.result, self)

        return