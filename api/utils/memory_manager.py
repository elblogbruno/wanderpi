# path utils is used for asking the user the path to the folder where the files are saved to in albums
# """


import os
import json

from schemas import MemoryDrive

class Singleton(type):
    def __init__(cls, name, bases, dict):
        super(Singleton, cls).__init__(name, bases, dict)
        cls.instance = None 

    def __call__(cls,*args,**kw):
        if cls.instance is None:
            cls.instance = super(Singleton, cls).__call__(*args, **kw)
        return cls.instance

class MemoryManager:
    # __metaclass__ = Singleton
    __instance = None
    
    def __init__(self, config_path, config_file_name, ask_at_start = False) -> None:
        if MemoryManager.__instance is None:
            MemoryManager.__instance = self
        else:
            raise Exception("This class is a singleton class")

        self.memories = []
        self.config_path = config_path
        self.config_file_name = config_file_name
        self.ask_at_start = ask_at_start
        self.start()

    @staticmethod
    def get_instance():
        if MemoryManager.__instance is None:
            MemoryManager.__instance = MemoryManager()
        return MemoryManager.__instance

    def get_drive(self, drive_id):
        for memory in self.memories:
            if memory.memory_id == drive_id:
                return memory
        return None

    def create_drive(self, drive_name):
        """
            This method creates a new drive
            :param drive_name: the name of the drive
            :return: the drive
        """
        drive = MemoryDrive(drive_name)
        self.memories.append(drive)
        return drive

    def delete_drive(self, drive_id):
        """
            This method deletes a drive
            :param drive_id: the id of the drive
            :return: the drive
        """
        for memory in self.memories:
            if memory.memory_id == drive_id:
                self.memories.remove(memory)
                self.save_memories_json()
                return memory
        return None

    def get_drives(self):
        return self.memories

    def start(self):
        print("Start config")
        
        if (os.path.exists(self.config_path) == False):
            # create config path folder if it does not exist
            os.makedirs(self.config_path)

        self.ask_and_save_memory_drives()

        # print each memory drive
        for memory in self.memories:
            print(memory.memory_type, memory.memory_access_uri)


    def ask_for_memory_input():
        """
            This method asks the user to enter the memory type and the memory access uri
            :return: the memory type and the memory access uri
        """
        memory_type = input("Please enter the memory type (local or cif): ")
        if memory_type == "local":
            memory_access_uri = input("Please enter the path to the folder where the files are saved to in albums: ")
        elif memory_type == "cif":
            print("Not implemented yet")
        return memory_type, memory_access_uri

    def save_memories_json(self):
        with open(self.final_path, 'w') as outfile:
            dic = {}
            dic["memories"] = []
            
            for memory in self.memories:
                dic["memories"].append(memory.dict())
            
            json.dump(dic, outfile)

    def ask_and_save_memory_drives(self):
        """
            This method asks the user the path to the folder where the files are saved to in albums
            :return: the path to the folder where the files are saved to in albums
        """
        self.final_path = self.config_path + self.config_file_name

        if os.path.exists(self.final_path):
            print("Config file exists")
            # read json config file
            with open(self.final_path) as json_file:
                data = json.load(json_file)
                print('Current memory drives:')
                for memory in data["memories"]:
                    drive = MemoryDrive(memory_type = memory["memory_type"], memory_access_uri = memory["memory_access_uri"], memory_id =memory["memory_id"])
                    self.memories.append(drive)
                    print("ID: " + memory["memory_id"] + " - Type: " + memory["memory_type"] + " -  Path: " + memory["memory_access_uri"])

            if self.ask_at_start:
                r = input("Do you want to add a new Memory Drive (y/n): ")
                
                while r == "y":
                    memory_type, memory_access_uri = MemoryManager.ask_for_memory_input()
                    drive = MemoryDrive(memory_type, memory_access_uri, str(len(self.memories)))
                    self.memories.append(drive)

                    self.save_memories_json()

                    r = input("Do you want to add another Memory Drive (y/n): ")
        
        else:
            print("Config file does not exist")
            r = input("Do you want to add a new Memory Drive (y/n): ")
            
            while r == "y":
                memory_type, memory_access_uri = MemoryManager.ask_for_memory_input()
                drive = MemoryDrive(memory_type = memory_type, memory_access_uri  = memory_access_uri, memory_id= str(len(self.memories)))
                self.memories.append(drive)

                self.save_memories_json()

                r = input("Do you want to add another Memory Drive (y/n): ")

        return self.memories


