import cv2
import threading
import uuid

class RecordingThread(threading.Thread):
    def __init__(self, name, camera):
        threading.Thread.__init__(self)
        self.name = name
        self.isRunning = True

        self.cap = camera
        fourcc = cv2.VideoWriter_fourcc(*'MP4V')
        self.video_id = str(uuid.uuid4()) 
        self.path = './controller/static/videos/' + str(self.video_id) + '.mp4'
        self.out = cv2.VideoWriter(self.path, fourcc, 20.0, (640, 480))
        self.latest_frame = None

    def run(self):
        while self.isRunning:
            ret, frame = self.cap.read()
            if ret:
                self.out.write(frame)
                self.latest_frame = frame

        self.out.release()

    def stop(self):
        self.isRunning = False

    def __del__(self):
        self.out.release()


class VideoCamera(object):
    def __init__(self, camera_id=0):
        # 打开摄像头， 0代表笔记本内置摄像头
        self.cap = cv2.VideoCapture(camera_id, cv2.CAP_DSHOW)

        # 初始化视频录制环境
        self.is_record = False
        self.out = None

        # 视频录制线程
        self.recordingThread = None

    # 退出程序释放摄像头
    def __del__(self):
        self.cap.release()

    def get_frame(self):
        ret, frame = self.cap.read()

        if ret:
            ret1, jpeg = cv2.imencode('.jpg', frame)

            if ret1:
                return jpeg.tobytes()

        else:
            return None

    def start_record(self):
        self.is_record = True
        self.recordingThread = RecordingThread("Video Recording Thread", self.cap)
        self.recordingThread.start()
        return self.recordingThread.video_id

    def stop_record(self):
        self.is_record = False

        if self.recordingThread != None:
            self.recordingThread.stop()

        thumbnail_url = "./controller/static/thumbnails/thumbnail-%s.jpg" % str(self.recordingThread.video_id)
        cv2.imwrite(thumbnail_url, self.recordingThread.latest_frame)

        return self.recordingThread.video_id