import os
import json

def create_folder(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
    except OSError:
        print('Error: Creating directory. ' + directory)

def ask_folder(logging):
    filename = os.path.join(os.getcwd(), 'settings.json')
    if os.path.isfile(filename):
        logging.info("Initiating with a found settings.json file.")
        with open(filename, 'r') as f:
            data = json.load(f)
        return data['custom_folder']
    else:
        print("Asking initially for a custom folder to save.")

        logging.info("Asking initially for a custom folder to save.")

        custom_folder = input("Which folder you'd like to save your wanderpis on ?:  ")

        logging.info("Using {} port".format(custom_folder))

        options = {
            'custom_folder': custom_folder
        }

        with open(filename, 'w') as outfile:
            json.dump(options, outfile)

        logging.info("Folder saved succesfully!")

        return options['custom_folder']
