# singleton class for database connection
from sqlalchemy.orm import Session

class DbManager:
    """
        This class is a singleton class for the database connection
        It is used to connect to the database and to execute queries
    """
    __instance = None
    def __init__(self, db_session: Session):
        print("DbManager: Initializing")
        print("DbManager: db_session: " + str(db_session))
        if DbManager.__instance is None:
            DbManager.__instance = self
        else:
            raise Exception("This class is a singleton class")

        self.db_session = db_session

    @staticmethod
    def get_instance():
        if DbManager.__instance is None:
            DbManager()
        return DbManager.__instance

    def get_db(self):
        return self.db_session