from django.http import HttpResponse
from .forms import UploadFileForm
from .scanner import scan_2_base64
from django.views.decorators.csrf import csrf_exempt
import base64
import json

# Create your views here.

@csrf_exempt
def scan(request):
    if request.method == "POST":
        image = request.FILES.get("imgFile", None)
        file = scan_2_base64(image.read())
        res = {'code': 20000, 'data': str(base64.b64encode(file.tobytes()))[2:-1], 'message': '操作成功'}
        response = HttpResponse(json.dumps(res))
        return response
    res = {'code': -1, 'message': '不支持的http方法'}
    return HttpResponse(json.dumps(res))