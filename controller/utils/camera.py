import cv2
import threading
import pyaudio
import wave
import numpy as np
import requests
import subprocess
import os
from moviepy.editor import *

from time import sleep
# import the necessary packages
try:
    from picamera.array import PiRGBArray # Generates a 3D RGB array
    from picamera import PiCamera # Provides a Python interface for the RPi Camera Module
except ImportError:
    print("Picamera not supported on windows")

import time # Provides time-related functions

class RecordingThread(threading.Thread):
    def __init__(self, name, camera, path, use_mjpg_cc = False):
        threading.Thread.__init__(self)
        self.isRunning = False
        self.name = name
        
        self.cap = camera
        self.fps = 30            
        
        if use_mjpg_cc:
            print("Using mjpg cc")
            self.fourcc = cv2.VideoWriter_fourcc(*'MJPG')
        else:
            print("Using FMP4 cc")
            self.fourcc = cv2.VideoWriter_fourcc(*'MP4V')

        # self.cap.set(cv2.CAP_PROP_FOURCC,  cv2.VideoWriter_fourcc(*'MP4V'))
        # self.cap.set(cv2.CAP_PROP_FPS, self.fps)
        # self.cap.set(cv2.CAP_PROP_BUFFERSIZE,  3)
        
        w = self.cap.get(cv2.CAP_PROP_FRAME_WIDTH)
        h = self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT)  
         
        self.path = path
        self.out = cv2.VideoWriter(self.path, self.fourcc, self.fps, (int(w),int(h)))
        
        self.frame_counts = 1
        self.start_time = time.time()

        
        self.video_time = 0
        self.isRunning = True
    def run(self):
        while self.isRunning:
            try:
                # Capture frame-by-frame
                ret, frame = self.cap.read()
                if ret:
                    self.out.write(frame)
                    self.frame_counts += 1
                    self.video_time =  time.time() - self.start_time
            except Exception as e: 
                print("Error recording {0}".format(str(e)))
                self.stop()

        #self.out.release()

    def stop(self):
        "Finishes the video recording therefore the thread too"
        if self.isRunning:
            self.isRunning = False
            #self.cap.release()
            self.out.release()

    def __del__(self):
        self.out.release()

class AudioRecorder():
    "Audio class based on pyAudio and Wave"
    def __init__(self, filename="temp_audio.wav", rate=44100, fpb=1024, channels=1):
        self.open = True
        self.rate = rate
        self.frames_per_buffer = fpb
        self.channels = channels
        self.format = pyaudio.paInt16
        self.audio_filename = filename
        self.audio = pyaudio.PyAudio()
        self.stream = self.audio.open(format=self.format,
                                      channels=self.channels,
                                      rate=self.rate,
                                      input=True,
                                      frames_per_buffer = self.frames_per_buffer)
        self.audio_frames = []

    def record(self):
        "Audio starts being recorded"
        self.stream.start_stream()
        while self.open:
            data = self.stream.read(self.frames_per_buffer) 
            self.audio_frames.append(data)
            if not self.open:
                break

    def stop(self):
        "Finishes the audio recording therefore the thread too"
        if self.open:
            self.open = False
            self.stream.stop_stream()
            self.stream.close()
            self.audio.terminate()
            waveFile = wave.open(self.audio_filename, 'wb')
            waveFile.setnchannels(self.channels)
            waveFile.setsampwidth(self.audio.get_sample_size(self.format))
            waveFile.setframerate(self.rate)
            waveFile.writeframes(b''.join(self.audio_frames))
            waveFile.close()
        
        pass

    def start(self):
        "Launches the audio recording function using a thread"
        audio_thread = threading.Thread(target=self.record)
        audio_thread.start()

class VideoCamera(object):
    def __init__(self, camera_id=0, is_mjpeg=False, is_picamera=False, username="", password=""):
        self.camera_id = camera_id
        self.is_picamera = is_picamera
        self.is_mjpeg = is_mjpeg
        
        
        if self.is_picamera:
            self.cap, self.raw_capture = self.init_picamera()
        elif not is_mjpeg:
            if 'mjpg' in str(camera_id):
                self.cap = cv2.VideoCapture(camera_id, cv2.CAP_OPENCV_MJPEG)
                self.use_mjpg_cc = True
            else:
                self.cap = cv2.VideoCapture(camera_id)
                self.use_mjpg_cc = False
        else:
            self.bytes = bytes()
            self.username = username
            self.password = password
            self.cap = None
            print(self.camera_id, username, password)
            self.stream = requests.get(self.camera_id, auth=(username,  password), stream=True)

        self.is_record = False
        self.out = None

        self.audio_thread = None
        self.recording_thread = None

    def init_picamera (self):
        camera = PiCamera()
        camera.resolution = (640, 480)
        camera.framerate = 20
        raw_capture = PiRGBArray(camera, size=(640, 480))
        time.sleep(0.1)
        return camera, raw_capture


    # def __del__(self):
    #     #self.cap.release()

    def get_frame(self):
        if self.is_picamera:
            for frame in self.cap.capture_continuous(self.raw_capture, format="bgr", use_video_port=True):
                
                # Grab the raw NumPy array representing the image
                image = frame.array
                
                if image:
                    ret1, jpeg = cv2.imencode('.jpg', frame)

                    if ret1:
                        return jpeg.tobytes()
                    
                
                    # Clear the stream in preparation for the next frame
                    self.raw_capture.truncate(0)

                else:
                    return None
        elif not self.is_mjpeg:
            try:
                ret, frame = self.cap.read()

                if ret:
                    ret1, jpeg = cv2.imencode('.jpg',frame)

                    if ret1:
                        return jpeg.tobytes()
                else:
                    return None
            except:
                return None
        else:
            if self.stream.status_code == 200:
                print("reading from mjpeg camera")
                for chunk in  self.stream.iter_content(chunk_size=1024):
                    self.bytes += chunk
                    a = self.bytes.find(b'\xff\xd8') # JPEG start
                    b = self.bytes.find(b'\xff\xd9') # JPEG end
                    if a !=-1 and b !=-1:
                        jpg = self.bytes[a:b+2] # actual image
                        self.bytes = self.bytes[b+2:] # other informations
                        
                        img = cv2.imdecode(np.fromstring(jpg, dtype=np.uint8),cv2.IMREAD_COLOR) 

                        return img.tobytes()
                    else:
                        return None
            else:
                print("Received unexpected status code {}".format(self.stream.status_code))
                return None

    def file_manager(self):
        "Required and wanted processing of final files"
        local_path = os.getcwd()
        if os.path.exists(str(local_path) + "/temp_audio.wav"):
            os.remove(str(local_path) + "/temp_audio.wav")
        # if os.path.exists(str(local_path) + "/temp_video.avi"):
        #     os.remove(str(local_path) + "/temp_video.avi")
        # if os.path.exists(str(local_path) + "/temp_video2.avi"):
        #     os.remove(str(local_path) + "/temp_video2.avi")

    def start_record(self, path, file_id):
        self.file_id = file_id
        self.is_record = True
        self.recording_thread = RecordingThread("Video Recording Thread", self.cap, path, self.use_mjpg_cc)
        self.audio_thread = AudioRecorder()

        self.audio_thread.start()
        self.recording_thread.start()
        return True

    def stop_record(self):
        self.is_record = False

        if self.audio_thread != None:
            self.audio_thread.stop()
        
        if self.recording_thread != None:
            self.recording_thread.stop()

        frame_counts = self.recording_thread.frame_counts
        elapsed_time = time.time() - self.recording_thread.start_time
        recorded_fps = frame_counts / elapsed_time

        print("total frames " + str(frame_counts))
        print("elapsed time " + str(elapsed_time))
        print("recorded fps " + str(recorded_fps))

        
        video_path = self.recording_thread.path
        path_temp = video_path.replace('.mp4', '-edited')

        if 'mp4' not in path_temp:
            path_temp += '.mp4'

        
        videoclip = VideoFileClip(video_path, audio=False)
        audioclip = AudioFileClip("./temp_audio.wav")

        new_audioclip = CompositeAudioClip([audioclip])
        
        videoclip.audio = new_audioclip
        videoclip.write_videofile(path_temp, threads=4, audio_codec='aac')

        os.remove(video_path)
        os.rename(path_temp, video_path)

        self.file_manager()

        return self.file_id

    