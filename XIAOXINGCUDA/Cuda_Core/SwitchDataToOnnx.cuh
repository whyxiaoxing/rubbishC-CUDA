#ifndef SWITCHDATATOONNX
#define SWITCHDATATOONNX

#include <cuda_runtime.h>

class SwitchDataToOnnx
{

    private:
    size_t yifenpeixiancun_allocatedvram;
    size_t xuyaoxiancun_needvram;

    int2 _dim3data;
    
    public:
    
    //预分配显存宽度 dim3的x，dim3的y
    SwitchDataToOnnx(size_t witch,int _g=64, int _b=8);
    SwitchDataToOnnx(const SwitchDataToOnnx&) = delete;
    SwitchDataToOnnx& operator=(const SwitchDataToOnnx&) = delete;
    void DISPOSE();

    float* shuchuzhizhen_outputfloat;

    // 输入指针 cuda流 输入宽度 输入高度 目标宽度 
    void xiaoxing_SwitchOnnxData(uchar4* shuruzhizhen_inputuchar,cudaStream_t cudastream,int inputwidth,int inputhight ,int targetheight=128);


  
};

#endif