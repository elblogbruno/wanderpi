from flask import Blueprint

# 创建蓝图对象
api_blu = Blueprint("api", __name__)

# 让视图函数和主程序建立关联
from controller.modules.api.views import *
