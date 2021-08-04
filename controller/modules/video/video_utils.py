import moviepy.editor as mp

class VideoUtils:
    @staticmethod
    def get_video_info(path):
        """
        Returns a dictionary with the video info.
        """
        #vid_info = ffmpeg.probe(path)
        #vid_info = "dsds"
        return mp.VideoFileClip(path).duration