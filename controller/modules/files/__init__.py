from flask import Blueprint

# 创建蓝图对象
files_blu = Blueprint("files", __name__)

# 让视图函数和主程序建立关联
from controller.modules.files.views import *
