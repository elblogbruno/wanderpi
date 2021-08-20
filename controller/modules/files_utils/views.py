from controller.modules.files.views import get_travel_folder_path
from flask import send_from_directory
from werkzeug.utils import secure_filename


from controller.models.models import Wanderpi
from controller.modules.files_utils import files_utils_blu
from controller.utils.video_editor import VideoEditor
from controller.utils.image_editor import ImageEditor

@files_utils_blu.route('/uploads/<string:travel_id>/<string:filename>', methods=['GET', 'POST'])
def download_file(travel_id, filename):
    file = Wanderpi.get_by_id(filename)
    file_type = 'images' if file.is_image else 'videos'
    abs_file_path = get_travel_folder_path(travel_id=travel_id, file_type=file_type)
    #file_path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=filename, file_type=file_type)
    
    if '.' not in filename: 
        filename = file.file_path.split('/')[-1]
    
    return send_from_directory(abs_file_path, filename, as_attachment=True)


@files_utils_blu.route('/get_share_image/<string:travel_id>/<string:filename>', methods=['GET', 'POST'])
def get_share_image(travel_id, filename):
    file = Wanderpi.get_by_id(filename)
    file_type = 'images' if file.is_image else 'videos'
    abs_file_path = get_travel_folder_path(travel_id=travel_id, file_type=file_type)
    
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
    ImageEditor.duplicated_image_with_different_name('./controller'+file.file_path, new_name_path)
    ImageEditor.add_watermark(new_name_path, './controller/static/logo-watermark.png', 100)

    

    return send_from_directory(abs_file_path, new_name, as_attachment=True)
