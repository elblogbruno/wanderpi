# task base class that is a thread that runs a task and calls the callback functions
# when the task is complete
#
import threading

class BaseTask(threading.Thread):
    def __init__(self, task_id, task_type, task_progress, task_progress_callback, task_callback):
        threading.Thread.__init__(self)

        self.task_id = task_id
        self.task_type = task_type
        self.task_status = 'started'

        self.task_progress = task_progress
        self.task_callback = task_callback
        self.task_progress_callback = task_progress_callback

        self.result = None
    
    def run(self):
        self.task_status = "running"
        self.task_callback(self.task_id,  self.task_type, self.task_status, self.task_progress, self.result, self.task_error)
        return
    
    def start(self):
        self.task_status = "started"
        super().start()
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

    def complete(self):
        self.task_status = "complete"

        if self.result is not None:
            self.task_callback(self.result)

        return 