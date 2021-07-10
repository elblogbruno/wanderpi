from typing import Mapping
import cv2
import os, ffmpeg

def record_video_from_camera():
    cap = cv2.VideoCapture("rtsp://192.168.1.10:554/user=admin_password=VyJdSdKg_channel=0_stream=1.sdp?real_stream")

    # Check if camera opened successfully
    if cap.isOpened() == False: 
        print("Unable to read camera feed")
        return

    cap.set(3,1920)
    cap.set(4,1080)
    # Default resolutions of the frame are obtained.The default resolutions are system dependent.
    # We convert the resolutions from float to integer.
    frame_width = int(cap.get(3))
    frame_height = int(cap.get(4))
    
    counter = 0
    # Define the codec and create VideoWriter object.The output is stored in 'outpy.avi' file.
    _fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    out = cv2.VideoWriter('input.mp4',_fourcc, 20.0, (frame_width,frame_height))

    while(cap.isOpened()):
        ret, frame = cap.read()
        # Write the frame into the file 'output.avi'
        out.write(frame)
        counter += 1
        cv2.imshow('frame', frame)
        if cv2.waitKey(20) & 0xFF == ord('q'):
            break

    cap.release()
    out.release()
    cv2.destroyAllWindows()

    return counter



def compress_video(video_full_path, output_file_name, target_size):
    # Reference: https://en.wikipedia.org/wiki/Bit_rate#Encoding_bit_rate
    min_audio_bitrate = 32000
    max_audio_bitrate = 256000

    probe = ffmpeg.probe(video_full_path)
    # Video duration, in s.
    duration = float(probe['format']['duration'])
    # Audio bitrate, in bps.
    audio_bitrate = float(next((s for s in probe['streams'] if s['codec_type'] == 'audio'), None)['bit_rate'])
    # Target total bitrate, in bps.
    target_total_bitrate = (target_size * 1024 * 8) / (1.073741824 * duration)

    # Target audio bitrate, in bps
    if 10 * audio_bitrate > target_total_bitrate:
        audio_bitrate = target_total_bitrate / 10
        if audio_bitrate < min_audio_bitrate < target_total_bitrate:
            audio_bitrate = min_audio_bitrate
        elif audio_bitrate > max_audio_bitrate:
            audio_bitrate = max_audio_bitrate
    # Target video bitrate, in bps.
    video_bitrate = target_total_bitrate - audio_bitrate

    i = ffmpeg.input(video_full_path)
    ffmpeg.output(i, os.devnull,
                  **{'c:v': 'libx264', 'b:v': video_bitrate, 'pass': 1, 'f': 'mp4'}
                  ).overwrite_output().run()
    ffmpeg.output(i, output_file_name,
                  **{'c:v': 'libx264', 'b:v': video_bitrate, 'pass': 2, 'c:a': 'aac', 'b:a': audio_bitrate}
                  ).overwrite_output().run()

duration = record_video_from_camera()

best_min_size = (32000 + 100000) * (1.073741824 * duration) / (8 * 1024)

print("Compressing video with this size target {0}".format(best_min_size))

try:    
    compress_video('input.mp4', 'output.mp4', best_min_size)
except FileNotFoundError as e:
    print(e)