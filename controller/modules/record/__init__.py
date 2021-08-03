from flask import Blueprint

# 创建蓝图对象
record_blu = Blueprint("record", __name__)

# 让视图函数和主程序建立关联
from controller.modules.record.views import *
