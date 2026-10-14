// 这里输出的是紧凑连续的 uchar4（RGBA）
#include "ERROR.cuh"
#include "tools.cuh"
#include "XIAOXING_CUDAkenel.cuh"
#include "d3dtocuda.cuh"
#include <cuda_runtime.h>
#include <exception>




D3D_To_Cuda::D3D_To_Cuda(ID3D11Texture2D* d3dzhizhen,int i_kuan,int i_gao,int2 i_block)
    : cudaforidi11ziyuan_cudad3dresource(nullptr),
      lingshishuzuh_temparray(nullptr),
      a(cudaSuccess),
      d3ddaoucharzhizhen_d3dtouchar(nullptr)
{   
    kuan=i_kuan;
    gao = i_gao;
    if (d3dzhizhen == nullptr)
    {
        XIAOXING_CUSTOMERROR("CPU"," d3dtocuda.cu","导入的D3Dtexture指针是空的 ");
    }
    bool a=false;
    // 注册cuda资源 这里需要进行预热
    XIAOXING_CHECK_CUDA(cudaGraphicsD3D11RegisterResource(&cudaforidi11ziyuan_cudad3dresource, d3dzhizhen, cudaGraphicsRegisterFlagsNone), " 在注册D3D11texture资源时候发生了错误, 如果你是用户请检查是否有足够的显存 " );
    XIAOXING_CUDA_Malloc(d3ddaoucharzhizhen_d3dtouchar,kuan,gao,a);
    if (!a)
    {
        cudaGraphicsUnregisterResource(cudaforidi11ziyuan_cudad3dresource);
        cudaforidi11ziyuan_cudad3dresource = nullptr;
        XIAOXING_CUSTOMERROR("GPU","d3dtochuda.cu"," 首次分配显存失败,如果你是用户请检查显存是否满了 ");
    }
    
    lingshishuzuh_temparray=NULL;
    a=cudaSuccess;
    blockcanshu=i_block;

}


void D3D_To_Cuda::dispose()
{   if (cudaforidi11ziyuan_cudad3dresource)
    {
        cudaGraphicsUnregisterResource(cudaforidi11ziyuan_cudad3dresource);
        cudaforidi11ziyuan_cudad3dresource = nullptr;
    }
    XIAOXING_Dispose_CUDAFree(d3ddaoucharzhizhen_d3dtouchar);
    d3ddaoucharzhizhen_d3dtouchar = nullptr;
    lingshishuzuh_temparray = NULL;

}

bool D3D_To_Cuda::xiaoxing_d3d_to_cuda(cudaStream_t stream )
{   
    lingshishuzuh_temparray = NULL;
    cudaResourceDesc  ziyuanwenli_resourcedesc;
    cudaTextureDesc tupianwenli_texturdesc;
    
    // 将注册的资源转为 cudaarray_t
    XIAOXING_CHECK_CUDA(cudaGraphicsMapResources(1,&cudaforidi11ziyuan_cudad3dresource,stream), " 转换d3d11texture为cudaarray发生了不可预测的错误 ");
    XIAOXING_CHECK_CUDA(cudaGraphicsSubResourceGetMappedArray(&lingshishuzuh_temparray, cudaforidi11ziyuan_cudad3dresource, 0, 0)," 转换d3d11texture为cudaarray发生了不可预测的错误 ");
    
    if (lingshishuzuh_temparray == NULL)
    {
        cudaGraphicsUnmapResources(1,&cudaforidi11ziyuan_cudad3dresource,stream);
        XIAOXING_CUSTOMERROR("GPU","d3dtochuda.cu"," cudaarray_t 为空 获取D3D资源失败 ");
        
    }

    // 还要创建一层 cudaTextureObject_t 生命周期随着函数， 且已经调教AI 3天才有的结果

    // 描述资源纹理
    memset(&ziyuanwenli_resourcedesc, 0, sizeof(cudaResourceDesc));
    ziyuanwenli_resourcedesc.resType=cudaResourceTypeArray;
    ziyuanwenli_resourcedesc.res.array.array = lingshishuzuh_temparray;
    // 设定 cudaTextureObject 读取方式
    memset(&tupianwenli_texturdesc, 0, sizeof(cudaTextureDesc));
    tupianwenli_texturdesc.addressMode[0] = cudaAddressModeClamp;
    tupianwenli_texturdesc.addressMode[1] = cudaAddressModeClamp;
    tupianwenli_texturdesc.filterMode = cudaFilterModePoint;
    tupianwenli_texturdesc.readMode = cudaReadModeElementType;
    tupianwenli_texturdesc.normalizedCoords = 0;

    
    // 创建纹理对象
    cudaTextureObject_t tupianduixiang_texturobject =0 ;
    a =cudaCreateTextureObject(&tupianduixiang_texturobject, &ziyuanwenli_resourcedesc, &tupianwenli_texturdesc, NULL);
    if (a !=cudaSuccess|| tupianduixiang_texturobject == 0)
    {   
         cudaGraphicsUnmapResources(1,&cudaforidi11ziyuan_cudad3dresource,stream);
         XIAOXING_CUSTOMERROR("GPU"," d3dtochuda.cu","创建纹理对象失败 ");
        
    }
    
    // 使用cuda核 一步转为 uchar4 并 BGRA 转为 RGBA 
    
    dim3 block(blockcanshu.x,blockcanshu.y); // dim3(32,4)  第一个参数
    dim3 grid((kuan + block.x - 1) / block.x, (gao + block.y - 1) / block.y);

    // CUDAKernel_two::test::XIAOXING_CUDAKenel_test<<<grid,block,0,stream >>>(tupianduixiang_texturobject,d3ddaoucharzhizhen_d3dtouchar,kuan,gao);
    CUDAKernel_two::Id3dtouchar::XIAOXING_CUDAKernel<<<grid, block, 0, stream>>>(tupianduixiang_texturobject, d3ddaoucharzhizhen_d3dtouchar, kuan, gao);
    XIAOXING_CHECK_CUDA(cudaGetLastError()," CUDA核计算发生不可预测错误,可能是数组越界或者计算错误,位于d3dtocuda.cu ");   
    // 最后必须释放
    cudaDestroyTextureObject(tupianduixiang_texturobject);
    cudaGraphicsUnmapResources(1, &cudaforidi11ziyuan_cudad3dresource, stream);
    return true;
}
