from flask import Blueprint

# 创建蓝图对象
video_blu = Blueprint("video", __name__)

# 让视图函数和主程序建立关联
from controller.modules.video.views import *
