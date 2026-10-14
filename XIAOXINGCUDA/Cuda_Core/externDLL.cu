// 计划把所有类全部在这里导出, 方便调用
#include "d3dtocuda.cuh"
#include "Found_F_SourceCode.cuh"
#include "PIC_Cut_Size.cuh"
#include "SimpleIni.h"
#include "SwitchDataToOnnx.cuh"

// 在正式版的时候请把下面这个头文件删除
#include "supper_the_test.cuh"


#include <windows.h>
#include <d3d11.h>
#include <cuda_runtime.h>
#include <new>
#include <string>
#include <stdexcept>
#include <sstream>

struct inishuju
{
    int d3dblock_x=0;
    int d3dblock_y=0;
    int SWDTOnnx_x=0;
    int SWDTOnnx_y=0;
    int yonghufenbianlv=0;

    int GPU=0;
    int Onnxfloatwidth;
    //开发者参数,正式版请删除
    bool SaveJpg=false;
    int  SaveJpgName=0;
    char path[256];
    int SaveFrequency=0;

    int2 xunzhaofchicun;

}inib;

void duquiniwenjian (){

    CSimpleIniA simpleini;
    try
    {
        if(simpleini.LoadFile("./XIAOXING_CUDA.ini")<0)throw std::runtime_error(" 加载XIAOXING_CUDA.ini失败 ");

        inib.GPU= std::atoi(simpleini.GetValue("USERMESSAGE","GPU","0"));
        inib.d3dblock_x= std::atoi(simpleini.GetValue("d3dtocuda","threadwidth","32"));
        inib.d3dblock_y= std::atoi(simpleini.GetValue("d3dtocuda","threadhight","4"));
        inib.yonghufenbianlv= std::atoi(simpleini.GetValue("USERMESSAGE","screen","0"));
        inib.SWDTOnnx_x = std::atoi(simpleini.GetValue("SWDTOnnx","threadwidth","64"));
        inib.SWDTOnnx_y = std::atoi(simpleini.GetValue("SWDTOnnx","threadhight","8"));
        inib.Onnxfloatwidth=std::atoi(simpleini.GetValue("USERMESSAGE","floatdatawidth","1024"));
        
        //开发者参数
        inib.SaveJpg=simpleini.GetBoolValue("DEPmessage","SaveJpeg",false);
        inib.SaveFrequency= std::atoi(simpleini.GetValue("DEPmessage","SaveFrequency","50"));
        // 关键值校验
        if (inib.yonghufenbianlv == 0)throw std::runtime_error(" ini文件内容不全,出现空值 ");

    }
    catch(const std::exception& e)
    {
       throw std::runtime_error(std::string(" 在读取ini时候发生错误: ") + e.what());
    }

}

std::tuple<int,int,int> enumfenbianlv(int screen,int defaultx=480,int defaulty=70,int defaultfoundx=80){

    int height = 1440;

    if (screen == 1)
    {
        height = 1080;
    }
    else if (screen == 2)
    {
        height = 1440;
    }
    else if (screen == 3)
    {
        height = 1620;
    }
    else if (screen == 4)
    {
        height = 2160;
    }
    else
    {
       throw  std::runtime_error(" 不支持的分辨率 ");
    }

    double scale = (double)height / 1440.0;

    int x =(int)std::ceil((double)defaultx * scale);
    int y = (int)std::ceil((double)defaulty * scale);
    int foundx = (int)std::ceil((double)defaultfoundx * scale);

    return std::tuple<int,int,int>(x,y,foundx);
}


#pragma comment(lib, "d3d11.lib")

#ifdef _WIN32
#define XIAOXING_API extern "C" __declspec(dllexport)
#else
#define XIAOXING_API extern "C"
#endif

int2 yuantuchicun;
ID3D11Texture2D* d3dzhizhen=nullptr;
Pic_Cut_Size* size=nullptr;
Found_F_SourceCode* foundF=nullptr;
D3D_To_Cuda*  d3dtocuda=nullptr;
SwitchDataToOnnx* swdtonnx=nullptr;

cudaStream_t liucheng_cudastream=nullptr;
thread_local std::string xiaoxing_last_error_message;

float* Onnxzhizhen=nullptr;

// 正式版请把这里删除
CudaArray_TO_JPG* Tojpg=nullptr;


static void xiaoxingclearerror(){
    xiaoxing_last_error_message.clear();
}

static void xiaoxingseterror(const char* message){
    xiaoxing_last_error_message = (message != nullptr) ? message : "";
}

static void xiaoxingseterror(const std::string& message){
    xiaoxing_last_error_message = message;
}

static void xiaoxingcleanupafterinitfail(){
    try{
        if (size!=nullptr){
            size->dispose();
            delete size;
            size = nullptr;
        }
    }catch(...){
        size = nullptr;
    }
    try{
        if (d3dtocuda!=nullptr){
            d3dtocuda->dispose();
            delete d3dtocuda;
            d3dtocuda = nullptr;
        }
    }catch(...){
        d3dtocuda = nullptr;
    }
    try{
        if (foundF!=nullptr){
            foundF->dispose();
            delete foundF;
            foundF = nullptr;
        }
    }catch(...){
        foundF = nullptr;
    }
    try{
        if (Tojpg!=nullptr){
            Tojpg->dispsoe();
            delete Tojpg;
            Tojpg = nullptr;
        }
    }catch(...){
        Tojpg = nullptr;
    }
    if (liucheng_cudastream!=nullptr){
        cudaStreamDestroy(liucheng_cudastream);
        liucheng_cudastream = nullptr;
    }
}



XIAOXING_API void XIAOXINGDLLCHUSHI(int tupiankuandu, int tupiangaodu, void*ID3DIntptr  ){
    
    // 先进行ini文件读取
    try
    {
        xiaoxingclearerror();
        duquiniwenjian();
        Sleep(30);
        printf(" set NVIDIA device ");
        cudaError_t setdevice_result = cudaSetDevice(inib.GPU);
       
        if (setdevice_result != cudaSuccess)
        {
            xiaoxingseterror(std::string("XIAOXINGDLLCHUSHI cudaSetDevice失败: ") + cudaGetErrorString(setdevice_result));
            return;
        }
        printf(" set NVIDIA success ");
        yuantuchicun = make_int2(tupiankuandu, tupiangaodu);

        printf(" check input value ");
        if (tupiankuandu==0||tupiangaodu==0 || ID3DIntptr==nullptr)
        {
            std::ostringstream oss;
            oss
                << "XIAOXINGDLLCHUSHI 参数不足: width=" << tupiankuandu
                << ", height=" << tupiangaodu
                << ", ID3DIntptr=" << ID3DIntptr;
            xiaoxingseterror(oss.str());
            return;
        }

        printf(" create cudastrame ");
        cudaError_t a =cudaStreamCreate(&liucheng_cudastream);
        if (a!=cudaSuccess){
            liucheng_cudastream=nullptr;
            xiaoxingseterror(std::string(" XIAOXINGDLLCHUSHI cudaStreamCreate失败: ") + cudaGetErrorString(a));
            return;
        }
        
        auto [q,w,e]= enumfenbianlv(inib.yonghufenbianlv);

        size=new Pic_Cut_Size();
        foundF = new Found_F_SourceCode(q,w,e);
        d3dtocuda = new D3D_To_Cuda(static_cast<ID3D11Texture2D*>(ID3DIntptr),yuantuchicun.x,yuantuchicun.y,make_int2(inib.d3dblock_x,inib.d3dblock_y));
        d3dtocuda->xiaoxing_d3d_to_cuda(liucheng_cudastream);
        Tojpg = new CudaArray_TO_JPG();
        swdtonnx = new SwitchDataToOnnx(inib.Onnxfloatwidth,inib.SWDTOnnx_x,inib.SWDTOnnx_y);

        if (size==nullptr||d3dtocuda==nullptr||foundF==nullptr||liucheng_cudastream==nullptr){
            xiaoxingseterror(std::string(" XIAOXINGDLLCHUSHI 初始化结束但状态异常: ") );
            xiaoxingcleanupafterinitfail();
            return;
        }
        xiaoxingclearerror();
    }
    catch(const std::exception& e)
    {
        std::string message = std::string(" XIAOXINGDLLCHUSHI 异常: ") + e.what() ;
        xiaoxingcleanupafterinitfail();
        xiaoxingseterror(message);
        return;
    }
    catch(...)
    {
        std::string message = std::string(" XIAOXINGDLLCHUSHI 未知异常  ");
        xiaoxingcleanupafterinitfail();
        xiaoxingseterror(message);
        return;
    }
}

XIAOXING_API void DISPOSE(){

    xiaoxingclearerror();
    
    try
    {
        size->dispose();
        d3dtocuda->dispose();
        foundF->dispose();
        swdtonnx->DISPOSE();
        
        
        
        delete size;
        delete d3dtocuda;
        delete foundF;
        delete swdtonnx;

        size = nullptr;
        d3dtocuda = nullptr;
        foundF = nullptr;
        swdtonnx = nullptr;

        Onnxzhizhen = nullptr;

        // 正式版请把这里删除
        Tojpg->dispsoe();
        delete Tojpg;
        Tojpg = nullptr;

        cudaStreamSynchronize(liucheng_cudastream);
        cudaStreamDestroy(liucheng_cudastream);
        liucheng_cudastream = nullptr;

        return;
    }
    catch(const std::exception& e)
    {
        xiaoxingseterror(std::string("DISPOSE 异常: ") + e.what() );
        return;
    }
    catch(...)
    {
        xiaoxingseterror(std::string("DISPOSE 未知异常  ") );
        return;
    }
}

XIAOXING_API void DANCIZHUANHUAN(){

    xiaoxingclearerror();
    if (size==nullptr||d3dtocuda==nullptr||foundF==nullptr||liucheng_cudastream==nullptr){
        xiaoxingseterror(std::string("DANCIZHUANHUAN called before init  ") );
        return;
    }
    try
    {   
        // 千万不要删除， 这里指针作用是防止ROI裁剪中 计算叠加， 按照道理 上一次的修改不会叠加到下一次中
        uchar4* dangqianzhen_cuda_zhizhen = d3dtocuda->d3ddaoucharzhizhen_d3dtouchar;
        
        d3dtocuda->xiaoxing_d3d_to_cuda(liucheng_cudastream);
        
        size->xiaoxing_cudacutsize(dangqianzhen_cuda_zhizhen,
                make_float2(0.57, 0.77),
                make_float2(0.31, 0.69),
                yuantuchicun
            );
        // 正式版请把这里删除 
        if(inib.SaveJpg && inib.SaveFrequency > 0){
            if(inib.SaveJpgName % inib.SaveFrequency == 0){
                sprintf(inib.path,"./log/Cut%d.jpg",inib.SaveJpgName);
                Tojpg->xiaoxing_cudaarray_to_jpg(size->shuchukuandu_output_w,size->shuchugaodu_output_h,dangqianzhen_cuda_zhizhen,inib.path,static_cast<size_t>(yuantuchicun.x) * sizeof(uchar4));}}


        if (!foundF->xiaoxing_Found_F(
            dangqianzhen_cuda_zhizhen,
            size->shuchukuandu_output_w,
            size->shuchugaodu_output_h,
            yuantuchicun,
            liucheng_cudastream)
        )
        { 
                return;
            
        } 
         // 正式版请把这里删除 
        if(inib.SaveJpg && inib.SaveFrequency > 0){
            
            if(inib.SaveJpgName % inib.SaveFrequency == 0){
                sprintf(inib.path,"./log/FoundF%d.jpg",inib.SaveJpgName);
                Tojpg->xiaoxing_cudaarray_to_jpg(foundF->shuchukuandu_output_w,foundF->shuchugaodu_output_h,dangqianzhen_cuda_zhizhen,inib.path,static_cast<size_t>(yuantuchicun.x) * sizeof(uchar4));}}
        inib.SaveJpgName ++;

        swdtonnx->xiaoxing_SwitchOnnxData(dangqianzhen_cuda_zhizhen,liucheng_cudastream,foundF->shuchukuandu_output_w,foundF->shuchugaodu_output_h);

    }
    catch(const std::exception& e)
    {
        xiaoxingseterror(std::string("DANCIZHUANHUAN 异常: ") + e.what() );
        return;
    }
    catch(...)
    {
        xiaoxingseterror(std::string("DANCIZHUANHUAN 未知异常 | ") );
        return;
    }
}

XIAOXING_API void XIAOXINLOOKERROR(char* buffer, int buffer_size){
    if (buffer == nullptr || buffer_size <= 0){
        return;
    }
    strncpy_s(buffer, static_cast<size_t>(buffer_size), xiaoxing_last_error_message.c_str(), _TRUNCATE);
}


