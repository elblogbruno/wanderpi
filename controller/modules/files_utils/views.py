from controller.modules.files.views import get_file_path
from flask import send_from_directory
from werkzeug.utils import secure_filename


from controller.models.models import Wanderpi
from controller.modules.files_utils import files_utils_blu
from controller.utils.video_editor import VideoEditor
from controller.utils.image_editor import ImageEditor
from config import load_custom_video_folder
import os
from uuid import UUID

def is_valid_uuid(uuid_to_test, version=4):
    """
    Check if uuid_to_test is a valid UUID.
    
     Parameters
    ----------
    uuid_to_test : str
    version : {1, 2, 3, 4}
    
     Returns
    -------
    `True` if uuid_to_test is a valid UUID, otherwise `False`.
    
     Examples
    --------
    >>> is_valid_uuid('c9bf9e57-1685-4c89-bafb-ff5af830be8a')
    True
    >>> is_valid_uuid('c9bf9e58')
    False
    """
    
    try:
        uuid_obj = UUID(uuid_to_test, version=version)
    except ValueError:
        return False
    return str(uuid_obj) == uuid_to_test

@files_utils_blu.route('/download_file/<string:travel_id>/<string:filename>', methods=['GET'])
def download_file(travel_id, filename):
    print(travel_id, filename)
    file = Wanderpi.get_by_id(filename)
    file_type = 'images' if file.is_image else 'videos'
    abs_file_path = get_file_path(travel_id=travel_id, stop_id=file.stop_id, file_type=file_type)
    file_path = get_file_path(travel_id=travel_id, stop_id=file.stop_id, filename_or_file_id=filename, file_type=file_type)
    
    # check if file exists, if it does not, maybe it is a custom video or photo
    if not os.path.exists(file_path):
        filename = Wanderpi.get_by_id(filename).name

    if '.' not in filename: 
        filename = file.file_path.split('/')[-1]
    
    try:
        return send_from_directory(abs_file_path, filename, as_attachment=True)
    except:
        print("Error sending from directory")
        return "File not available"

@files_utils_blu.route('/get_share_image/<string:travel_id>/<string:filename>', methods=['GET', 'POST'])
def get_share_image(travel_id, filename):
    file = Wanderpi.get_by_id(filename)
    file_type = 'images' if file.is_image else 'videos'
    abs_file_path = get_file_path(travel_id=travel_id, stop_id=file.stop_id, file_type=file_type)
    
    #ImageEditor.add_watermark(file.file_path, 'static/images/share_image_watermark.png', 100)
    if '.' not in filename: 
        filename = file.file_path.split('/')[-1]

    new_name = filename.split('.')[0] + '_share_image.png'
    new_name_path = file.file_path.replace(filename, new_name)

    size  = ImageEditor.get_image_size(file.file_path)

    fixed_height = round(500 / float(size[1]))
    if fixed_height == 0:
        fixed_height = 1
    #height_percent = (fixed_height / float(size[1]))
    #width_size = int((float(size[0]) * float(height_percent)))

    ImageEditor.resize_image('./controller/static/logo-watermark.png', new_height=int(fixed_height))
    ImageEditor.duplicated_image_with_different_name(file.file_path, new_name_path)
    ImageEditor.add_watermark(new_name_path, './controller/static/logo-watermark.png', 100)

    

    return send_from_directory(abs_file_path, new_name, as_attachment=True)
