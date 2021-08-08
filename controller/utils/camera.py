from controller.modules.files.views import get_travel_folder_path
import cv2
import threading
import uuid
import numpy as np
import requests
from time import sleep
# import the necessary packages
try:
    from picamera.array import PiRGBArray # Generates a 3D RGB array
    from picamera import PiCamera # Provides a Python interface for the RPi Camera Module
except ImportError:
    print("Picamera not supported on windows")

import time # Provides time-related functions

class RecordingThread(threading.Thread):
    def __init__(self, name, camera,path, use_mjpg_cc = False):
        threading.Thread.__init__(self)
        self.name = name
        self.isRunning = True
        self.cap = camera
        
        if use_mjpg_cc:
            print("Using mjpg cc")
            fourcc = cv2.VideoWriter_fourcc(*'MJPG')
        else:
            print("Using FMP4 cc")
            fourcc = cv2.VideoWriter_fourcc(*'MP4V')
      
        #self.video_id = str(uuid.uuid4()) 
        #self.path = './controller/static/videos/' + str(self.video_id) + '.mp4'
        
        self.path = path

        self.out = cv2.VideoWriter(self.path, fourcc, 25, (640, 480))
        #self.latest_frame = None

    def run(self):
        sleep(0.5)
        while self.isRunning:
            sleep(0.01)
            ret, frame = self.cap.read()
            if ret:
                self.out.write(frame)
                #self.latest_frame = frame

        self.out.release()

    def stop(self):
        self.isRunning = False

    def __del__(self):
        self.out.release()


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
                self.cap = cv2.VideoCapture(camera_id, cv2.CAP_ANY)
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

        self.recording_thread = None

    def init_picamera (self):
        camera = PiCamera()
        camera.resolution = (640, 480)
        camera.framerate = 20
        raw_capture = PiRGBArray(camera, size=(640, 480))
        time.sleep(0.1)
        return camera, raw_capture


    def __del__(self):
        self.cap.release()

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
            self.ret, self.frame = self.cap.read()

            if self.ret:
                ret1, jpeg = cv2.imencode('.jpg', self.frame)

                if ret1:
                    return jpeg.tobytes()

            else:
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

    def start_record(self, path, file_id):
        self.file_id = file_id
        self.is_record = True
        self.recording_thread = RecordingThread("Video Recording Thread", self.cap, path, self.use_mjpg_cc)
        self.recording_thread.start()
        return True

    def stop_record(self, travel_id):
        self.is_record = False

        if self.recording_thread != None:
            self.recording_thread.stop()

        #thumbnail_url = "./controller/static/thumbnails/thumbnail-%s.jpg" % str(self.video_id)
        # thumbnail_url = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=self.file_id, file_type='thumbnails')

        # if len(self.recording_thread.latest_frame) > 0:
        #     cv2.imwrite(thumbnail_url, self.recording_thread.latest_frame)
        # else:
        #     print("No frame to save")
        #     return None

        return self.file_id

    