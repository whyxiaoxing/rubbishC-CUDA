# 环境说明 
- vs2022+ 配置好cl.exe 位置 注意是64位的
  ``` base
    %你的vs位置%VC\Tools\MSVC\14.50.35717\bin\Hostx64\x64\cl.exe
  ```

- cuda tookit 
  >  内部自带 NPP 安装后自动识别

- vscode配置
  > vscode 的settings.json 需要修改
  ``` json 
    "files.associations": {
        "*.cu": "cuda-cpp",
        "*.cuh": "cuda-cpp"
    }
  ```

> 其余默认配置


# 文件夹说明
- HONG
  >宏定义 不包含 supper_the_test
- Found-F-SourceCode  
  > 寻找F字符
- PIC_Cut_Size
  > 裁剪图片
- supper_the_test
 > 测试用的代码 （此处杂乱）
- XIAOXING_CUDAKenel
  > cuda 核函数 supper_the_test 内部核函数不在此处定义


# 目标，修改bgi的OCR部分，采用F定位原则，并实现 DWM取图后-> OCR 部分

1. 获取 3d11texture2d 指针后 转为cuda array
2. 裁剪目标区域
3. 识别F位置并裁剪图片（裁剪后不带F）
4. 预处理后丢给ORT


## 要求 
1. 以c风格，数据类型为主
2. 面向对象写法
3. 手动实现dispoes
4. 以下要求
> 编写说明  顺序为： CUDA核函数 -> 工具函数 -> 功能函数
> 命名规则：XIAOXING_目的/功能 -> 类
> 命名规则：xiaoxing_目的/功能 -> 函数
> 命名规则：中文拼音_英文_自定义 -> 变量
> 命名规则：XIAOXING_CUDAkenel -> 核函数
>
---
> 使用紧凑型的显存

# 禁止内容
1. 禁止使用第三方库
2. 禁止使用 cudaMallocPitch