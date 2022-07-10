from watchdog.observers import Observer
# from watchdog.events import LoggingEventHandler
from watchdog.events import FileSystemEventHandler
from utils.db_manager import DbManager
from utils.file import FileUtils


import utils.users

class Handler(FileSystemEventHandler):
    
    

    # TODO: Create on create method and on delete method to handle the creation and deletion of files
    # when deleted we delete the element from the database
    # when created we add the element to the database


    @staticmethod
    def on_created(event):
        """Called when a file or directory is created.

        :param event:
            Event representing file/directory creation.
        :type event:
            :class:`DirCreatedEvent` or :class:`FileCreatedEvent`
        """
        print('CREATED: ' + event.src_path)
        print(event)
        
        known_faces = utils.users.get_users(DbManager.get_instance().get_db()) 

        # for every file created, run the task
        FileUtils.process_file(event.src_path, known_faces)

    @staticmethod
    def on_deleted(event):
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
    def __init__(self, memories):
        
        self.observers = []

        for memory in memories:
            print("Watching: " + memory.memory_access_uri)
            observer = Observer()
            # self.event_handler = LoggingEventHandler()
            
            event_handler = Handler()
            observer.schedule(event_handler, memory.memory_access_uri , recursive=True)
            observer.start()

            self.observers.append(observer)

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