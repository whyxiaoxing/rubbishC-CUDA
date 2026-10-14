#ifndef D3DTOCUDA_H
#define D3DTOCUDA_H


#include <cuda_runtime.h>
#include <cuda_d3d11_interop.h>
#include <d3d11.h>

class D3D_To_Cuda
{
private:
   
    cudaGraphicsResource* cudaforidi11ziyuan_cudad3dresource;
    cudaArray_t lingshishuzuh_temparray;
    cudaError_t a;
    int kuan,gao;
    int2 blockcanshu;

public:
    // 对外输出的指针，非托管，属于该函数内dispose托管，不要主动释放
    uchar4* d3ddaoucharzhizhen_d3dtouchar;
    D3D_To_Cuda(ID3D11Texture2D* d3dzhizhen,int kuan,int gao,int2 i_block);
    D3D_To_Cuda(const D3D_To_Cuda&) = delete;
    D3D_To_Cuda& operator=(const D3D_To_Cuda&) = delete;
    
    void dispose();
    // 重要改动，这里应该是void* 对接C#的 IntPtr 先转译为 ID3D11Texture2D* 这才是合规，但是这里是进入到内部处理 DLL导出时候才为void*
    bool xiaoxing_d3d_to_cuda(cudaStream_t stream );

};



#endif
