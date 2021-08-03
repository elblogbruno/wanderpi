from flask import Blueprint

# 创建蓝图对象
travel_blu = Blueprint("travel", __name__)

# 让视图函数和主程序建立关联
from controller.modules.travel.views import *
