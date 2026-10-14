#ifndef KERNEL_ONE_CUH
#define KERNEL_ONE_CUH
#include <cuda_runtime.h>
#include <npp.h>
#include <nvjpeg.h>

namespace CUDAKernel_one {

namespace Kernel_qu_se_qi {
// 函数架构， 根据F特征 y轴连续的黑色， x轴左侧有空白， 右侧有黑点
// 把判断逻辑 拆出来方便并发， 
// 并且判断逻辑应该是 原子化的


// 输入图片 字节宽度 图片高度，图片宽度，x起点，
// x终点，黑的值，白色值，颜色偏差，左侧检查，上下检查，F高度，
// f标志，f的y点，f的x点
__global__ void XIAOXING_CUDAKenel(
    uchar4* input,
    int input_origPic_width,
    int width,
    int height,
    int x_start,
    int x_end,
    int f_huisezhi_blackvale,
    int f_baisezhi_whitevale,
    int f_yansewucha_coloerdeviation,
    int f_zuocejianchaxiangsu_leftcheck,
    int f_dingbujianhedibujianchaxiangsu_topandbottomcheck,
    int f_jiancegaodu_fhight,
    int* f_found_flags,
    int* f_top_y,
    int* f_top_x
);
// 这是筛选数据
__global__ void XIAOXING_CUDAKenel2(
    int x_start,
    int x_end,
    int* f_found_flags,
    int* f_top_y,
    int* f_top_x
);

// 执行判定 非核函数不可调用
__device__ __forceinline__ static int xiaoxing_find_maybe_f( uchar4* input,
    int input_origPic_width,
    int width,
    int x,
    int height,
    int f_huisezhi_blackvale,
    int f_baisezhi_whitevale,
    int f_yansewucha_coloerdeviation,
    int f_zuocejianchaxiangsu_leftcheck,
    int f_dingbujianhedibujianchaxiangsu_topandbottomcheck,
    int f_jiancegaodu_fhight);

//非核函数不可调用
__device__ __forceinline__ static int xiaoxing_is_black_pixel(
    uchar4 p,
    int black,
    int deviation
);

//非核函数不可调用
__device__ __forceinline__ static int xiaoxing_is_white_pixel(
    uchar4 p,
    int white,
    int deviation
);

//非核函数不可调用
__device__ __forceinline__ static int xiaoxing_clamp_to_byte(int value);

}  

}  

namespace CUDAKernel_two{

    namespace Id3dtouchar{
        
        // BRG 转 RGB Id3dtexture转uchar  输入cudaTextureObject_t  目标uchar4 宽 高
        __global__ void XIAOXING_CUDAKernel( cudaTextureObject_t text_intput, uchar4* output, int width, int height );

        //非核函数不可调用
        __device__ __forceinline__ static uchar4 channelswitch_fast(uchar4 v);
    }
    // namespace test{ // 测试的接口
        
    //     // BRG 转 RGB Id3dtexture转uchar  输入cudaTextureObject_t  目标uchar4 宽 高 测试版本
    //      __global__ void XIAOXING_CUDAKenel_test(cudaTextureObject_t text_input,uchar4* output,int width,int height);

    //      //非核函数不可调用
    //      __device__ __forceinline__ static unsigned int  channelswitch_u32(unsigned int v);
    // }

}

namespace CUDAKernel_three{

    namespace to_chw{

         __global__ void XIAOXING_CUDAKenel(uchar4*  __restrict__ input,float*  __restrict__ output,int inputwidth,int inputhight ,int targetheight);

    }
}


#endif
