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
    
    @staticmethod
    def get_video_thumbnail(path, video_id):
        vcap = cv2.VideoCapture(path)
        res, im_ar = vcap.read()
        while im_ar.mean() < 1 and res:
            res, im_ar = vcap.read()

        #im_ar = cv2.resize(im_ar, (thumb_width, thumb_height), 0, 0, cv2.INTER_LINEAR)
        #to save we have two options
        #1) save on a file
        thumbnail_url = "./controller/static/thumbnails/thumbnail-%s.jpg" % str(video_id)
        
        cv2.imwrite(thumbnail_url, im_ar)

        return "/static/thumbnails/thumbnail-%s.jpg" % str(video_id)
        