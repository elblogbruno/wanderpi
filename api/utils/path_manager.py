# singleton class for database connection
import os

class PathManager:
    """
        This class is a singleton class for the database connection
        It is used to connect to the database and to execute queries
    """
    __instance = None
    def __init__(self):
        print("Path Manager: Initializing")
        if PathManager.__instance is None:
            PathManager.__instance = self
        else:
            raise Exception("This class is a singleton class")

        self.file_path = os.path.join(os.getcwd(), "api", "files")
        self.encoding_path = os.path.join(os.getcwd(), "api", "face_encodings")

        if  not os.path.exists(self.file_path):
            os.makedirs(self.encoding_path, exist_ok=True)

        if  not os.path.exists(self.encoding_path):
            os.makedirs(self.encoding_path, exist_ok=True)

    def calculate_path_for_file(self, filename, file_type = 'file'):
        if file_type == 'enconding':
            return os.path.join(self.encoding_path,  filename)

        return os.path.join(self.file_path,  filename)

    @staticmethod
    def get_instance():
        if PathManager.__instance is None:
            PathManager()
        return PathManager.__instance