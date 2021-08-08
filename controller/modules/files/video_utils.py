import random
import moviepy.editor as mp
import cv2
class VideoUtils:
    @staticmethod
    def get_video_info(path):
        """
        Returns a dictionary with the video info.
        """
        #vid_info = ffmpeg.probe(path)
        #vid_info = "dsds"
        return mp.VideoFileClip(path).duration
    
    # An example of abs file path is: ./controller/static/wanderpis/{travel-id}/thumbnail/thumbnail-{video-id}.jpg
    @staticmethod
    def save_video_thumbnail(file_path, abs_file_path, video_id):
        video = cv2.VideoCapture(file_path)
        
        total_frames = int(video.get(cv2.CAP_PROP_FRAME_COUNT))
        
        #get random number between 0 and total_frames
        frame_number = random.randint(0, total_frames)

        video.set(1, frame_number)
        ret, frame = video.read()

        #im_ar = cv2.resize(im_ar, (thumb_width, thumb_height), 0, 0, cv2.INTER_LINEAR)
        #to save we have two options
        #1) save on a file
        thumbnail_url = abs_file_path + "/thumbnail-%s.jpg" % str(video_id)
        if ret:
            cv2.imwrite(thumbnail_url, frame)
        else:
            print("Error reading video file")
        