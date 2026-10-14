#include "XIAOXING_CUDAkenel.cuh"
#include "tools.cuh"

#include <cuda_runtime.h>
#include "SwitchDataToOnnx.cuh"


SwitchDataToOnnx::SwitchDataToOnnx(size_t witch,int _g, int _b)
{

    shuchuzhizhen_outputfloat=nullptr;
    bool a;
    XIAOXING_CUDA_Malloc_PPOCRFloat(shuchuzhizhen_outputfloat,witch,130,a);
    if (!a)
    {
        XIAOXING_CUSTOMERROR(" CPU "," SwitchDataToOnnx.cu "," 发生了不可预测的显存分配错误 ");
    }
    yifenpeixiancun_allocatedvram = (size_t)witch * (size_t)130 * (size_t)3;

    _dim3data=make_int2(_g,_b);

}

void SwitchDataToOnnx::DISPOSE()
{

    XIAOXING_Dispose_CUDAFree(shuchuzhizhen_outputfloat);
    shuchuzhizhen_outputfloat = nullptr;
    yifenpeixiancun_allocatedvram = 0;
}

void SwitchDataToOnnx::xiaoxing_SwitchOnnxData(uchar4* shuruzhizhen_inputuchar,cudaStream_t cudastream,int inputwidth,int inputhight ,int targetheight)
{
    xuyaoxiancun_needvram =   (size_t)inputwidth *(size_t)targetheight *(size_t)3;
    if (yifenpeixiancun_allocatedvram < xuyaoxiancun_needvram)
    {
        XIAOXING_CUSTOMERROR(" CPU "," SwitchDataToOnnx.cu "," 分配的显存不足图片大小请修改ini中的配置 ");
    }
    
    dim3 block(_dim3data.x,_dim3data.y);
    dim3 grid(
    (inputwidth + block.x - 1) / block.x,(targetheight + block.y - 1) / block.y);


    CUDAKernel_three::to_chw::XIAOXING_CUDAKenel<<<grid,block,0,cudastream >>>(shuruzhizhen_inputuchar,shuchuzhizhen_outputfloat,inputwidth,inputhight,targetheight);
    XIAOXING_CHECK_CUDA(cudaGetLastError()," CUDA核计算发生不可预测错误,可能是数组越界或者计算错误,位于SwitchDataToOnnx.cu ");   

}
