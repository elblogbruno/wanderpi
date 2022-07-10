# task that reads file metadata like geolocation and stores it in the database

from background.tasks.base_task import BaseTask 

class GeoTask(BaseTask):
    def __init__(self, file_path, file_type, task_id, task_type, task_progress, task_callback):
        BaseTask.__init__(self, task_id,  task_type, task_progress, task_callback) 
    
    def run(self):
        print("GeoTask started")
        self.task_status = "running"
        self.task_progress = 0
        self.task_result = None
        self.task_error = None
        return

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