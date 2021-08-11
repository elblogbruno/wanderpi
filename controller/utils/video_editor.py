#from controller.modules.files.views import get_travel_folder_path
from moviepy import *
from moviepy.editor import VideoFileClip, TextClip, CompositeVideoClip, concatenate_videoclips

import os
class VideoEditor:

    @staticmethod
    def AddTitleToVideo(video_path, video_id, travel_id, title="My Holidays 2013"):
        """
        Add a first clip to the video with the video title on the center of the screen
        """
        clip = VideoFileClip(video_path)

        w,h = moviesize = clip.size

        # clip = clip.subclip(0, clip.duration)
        # txt_clip = TextClip(title, fontsize=30, color='white').set_duration(1)
        # clip = CompositeVideoClip([clip, txt_clip])
        # clip = clip.set_pos(('center', 'bottom'))

        # A CLIP WITH A TEXT AND A BLACK SEMI-OPAQUE BACKGROUND

        txt = TextClip(title, font='Amiri-regular',
                        color='white',fontsize=24).set_duration(clip.duration)

        txt_col = txt.on_color(size=(clip.w + txt.w,txt.h-10),
                        color=(0,0,0), pos=(6,'center'), col_opacity=0.6)


        # THE TEXT CLIP IS ANIMATED.
        # I am *NOT* explaining the formula, understands who can/want.
        txt_mov = txt_col.set_pos( lambda t: (max(w/30,int(w-0.5*w*t)),
                                        max(5*h/6,int(100*t))))

        final = CompositeVideoClip([clip,txt_mov])
        
        path_temp = video_path.replace('.mp4', '-edited')

        if 'mp4' not in path_temp:
            path_temp += '.mp4'
        
        #path_temp = './controller/static/videos/' + str(video_id) + '-edited.mp4'

        final.write_videofile(path_temp, codec='libx264') 

        os.remove(video_path)
        os.rename(path_temp, video_path)
    
    @staticmethod
    def JoinVideos(videos_path, video_id, video_path):
        video_clips = []
        for path in videos_path:
            #we use VideoFileClip() class create two video object, then we will merge them.
            video_1 = VideoFileClip(path)
            video_clips.append(video_1)

        #Merge videos with concatenate_videoclips()
        final_video = concatenate_videoclips(video_clips)
        
       
        file_id = str(video_id) + '-edited'
        
        path_temp = video_path.replace('.mp4', '-edited')

        if 'mp4' not in path_temp:
            path_temp += '.mp4'

        final_video.write_videofile(path_temp, codec='libx264') 
        
        try:
            if os.path.exists(video_path):
                os.remove(video_path)
        except PermissionError as e:
            print(e)
        
        os.rename(path_temp, video_path)

        return video_path