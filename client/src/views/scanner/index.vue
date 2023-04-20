<template>
  <div style="padding-left: 5%; padding-top: 2%;">
    <el-upload
      class="upload-demo"
      ref="upload"
      action="string"
      accept="image/jpeg,image/png,image/jpg"
      list-type="picture-card"
      :before-upload="onBeforeUploadImage"
      :http-request="UploadImage"
      :on-change="fileChange"
      :file-list="fileList"
      drag
    >
    <div>
      <div class="el-upload__text">
        将文件拖到此处，或<em>点击上传</em>开始扫描
      </div>
      <div class="el-upload__tip" slot="tip">
        只能上传jpg/png文件，且不超过500kb
      </div>
    </div>
    </el-upload>

    <div v-if="imageUrl != ''">
      <p>扫描结果</p>
      <el-button @click="handleDownloadImg">下载</el-button>
      <br/>
      <el-image :src="imageUrl" style="width: 80%; padding-left: 5%;"/>
    </div>
  </div>
</template>

<script>
import { scan } from "@/api/scanner";

export default {
  name: "Scanner",
  data() {
    return {
      fileList: [],
      logo: "",
      imageUrl: "",
    };
  },
  methods: {
    onBeforeUploadImage(file) {
      const isIMAGE = file.type === "image/jpeg" || "image/jpg" || "image/png";
      if (!isIMAGE) {
        this.$message.error("上传文件只能是图片格式!");
      }
      return isIMAGE;
    },
    UploadImage(param) {
      const formData = new FormData();
      formData.append("imgFile", param.file);
      scan(formData)
        .then((response) => {
          console.log("上传图片成功");
          this.imageUrl = "data:image/jpg;base64," + response;
          param.onSuccess(); // 上传成功的图片会显示绿色的对勾
          // 但是我们上传成功了图片， fileList 里面的值却没有改变，还好有on-change指令可以使用
        })
        .catch((response) => {
          console.log("图片上传失败");
          param.onError();
        });
    },
    fileChange(file) {
      this.$refs.upload.clearFiles(); //清除文件对象
      this.logo = file.raw; // 取出上传文件的对象，在其它地方也可以使用
      this.fileList = [{ name: file.name, url: file.url }]; // 重新手动赋值filstList， 免得自定义上传成功了, 而fileList并没有动态改变， 这样每次都是上传一个对象
    },
    handleDownloadImg() {
      // 如果浏览器支持msSaveOrOpenBlob方法（也就是使用IE浏览器的时候），那么调用该方法去下载图片
      if (window.navigator.msSaveOrOpenBlob) {
        const bstr = atob(this.imageUrl.split(",")[1]);
        let n = bstr.length;
        const u8arr = new Uint8Array(n);
        while (n--) {
          u8arr[n] = bstr.charCodeAt(n);
        }
        const blob = new Blob([u8arr]);
        window.navigator.msSaveOrOpenBlob(blob, "扫描结果" + "." + "png");
      } else {
        // 这里就按照chrome等新版浏览器来处理
        const a = document.createElement("a");
        a.href = this.imageUrl;
        a.setAttribute("download", "扫描结果");
        a.click();
      }
    },
  },
};
</script>
