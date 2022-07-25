import os
from time import sleep

from watchdog.observers import Observer
# from watchdog.events import LoggingEventHandler
from watchdog.events import FileSystemEventHandler
from dependencies import *
from utils.db_manager import DbManager
from utils.file import FileUtils

import utils.users
import utils.wanderpis


class Handler(FileSystemEventHandler):
    # TODO: Create on create method and on delete method to handle the creation and deletion of files
    # when deleted we delete the element from the database
    # when created we add the element to the database
    
    def __init__(self, stop_id, path):
        self.stop_id = stop_id
        self.path = path
        self.current_status = ""

    # @staticmethod
    def on_created(self, event):
        """Called when a file or directory is created.

        :param event:
            Event representing file/directory creation.
        :type event:
            :class:`DirCreatedEvent` or :class:`FileCreatedEvent`
        """
        print('CREATED: ' + event.src_path)
        print(event)
        
        self.db_manager = DbManager.get_instance().get_db()
        base_name = os.path.basename(event.src_path)

        self.current_status = f"Uploading {base_name} to {self.path}"
        

        try:
            known_faces = utils.users.get_users(db = self.db_manager) 
            current_user =  get_local_current_user()

            print(current_user)

            if not current_user:
                print("Can't upload files if you are not logged in")

                return 

            # for every file created, run the task
            wanderpi = FileUtils.process_file(event.src_path, known_faces)        
            
            utils.wanderpis.create_wanderpi(self.db_manager, wanderpi, current_user=current_user, stop_id=self.stop_id)
            
            self.current_status = f"{wanderpi.name} uploaded successfully"
            print(self.current_status)
        
        except Exception as e:
            print(e)
            self.current_status = f"Error uploading {base_name} to {self.path}"
            sleep(0.5)
            self.current_status = str(e)
            print(self.current_status)

    # @staticmethod
    def on_deleted(self, event):
        """Called when a file or directory is deleted.

        :param event:
            Event representing file/directory deletion.
        :type event:
            :class:`DirDeletedEvent` or :class:`FileDeletedEvent`
        """
        print('DELETED: ' + event.src_path)
        print(event)

class UploadWatchdog:
    """ 
        This checks if the are new files in the upload folder
        if there are new files, it adds the new files to the database 
        running each different tasks.
    """
    __instance = None
    def __init__(self, memories):
        if UploadWatchdog.__instance is None:
            UploadWatchdog.__instance = self
        else:
            raise Exception("This class is a singleton class")
        
        self.observers = []
        self.handlers = []

        # TODO: this will not be added at start, they will be added at runtime when user wants to upload something.
        # WE create a folder where user can upload things and this will watch them.
        # TODO: Saved the runtime added paths to watch dog so when server is restarted we continue watchdogging the folders.

        # for memory in memories:
        #     print("Watching: " + memory.memory_access_uri)
        #     observer = Observer()
        #     # self.event_handler = LoggingEventHandler()
            
        #     event_handler = Handler()
        #     observer.schedule(event_handler, memory.memory_access_uri , recursive=True)
        #     observer.start()

        #     self.observers.append(observer)

    @staticmethod
    def get_instance():
        if UploadWatchdog.__instance is None:
            UploadWatchdog.__instance = UploadWatchdog()
        return UploadWatchdog.__instance

    def get_watchdog_status(self, path):
        print("Getting status for: " + path)
        print(self.handlers)

        # path is inside "", so we need to remove the ""
        # path = path[1:-1]

        for handler in self.handlers:
            print(handler.path)
            if os.path.samefile(handler.path, path):
                print(handler.current_status)
                return handler.current_status
        return "No status"

    def add_new_path_to_watch(self, path, stop_id):
        print(" Watching: " + path + " for stop: " + str(stop_id))
        observer = Observer()
        # self.event_handler = LoggingEventHandler()
        event_handler = Handler(stop_id, path)
        observer.schedule(event_handler, path, recursive=True)
        observer.start()

        self.observers.append(observer)
        self.handlers.append(event_handler)

    def run(self):
        try:
            while True:
                pass
        except KeyboardInterrupt:
            for observer in self.observers:
                observer.stop()
            print("UploadWatchdog stopped")

        for observer in self.observers:
            observer.join()