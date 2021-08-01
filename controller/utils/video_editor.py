from moviepy import *
from moviepy.editor import VideoFileClip, TextClip, CompositeVideoClip

import os
class VideoEditor:

    @staticmethod
    def AddTitleToVideo(video_path, title="My Holidays 2013"):
        """
        Add title to video
        """
        #video_path = os.path.abspath(video_path)
        # video = VideoFileClip(video_path)

        # # Make the text. Many more options are available.
        # txt_clip = ( TextClip(title,fontsize=70,color='white')
        #             .with_position('center')
        #             .with_duration(10) )

        # result = CompositeVideoClip([video, txt_clip]) # Overlay text on video
        # result.write_videofile(video_path, fps=25) 