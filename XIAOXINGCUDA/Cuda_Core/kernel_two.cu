#include "XIAOXING_CUDAkenel.cuh"
#include <cuda_runtime.h>

namespace CUDAKernel_two{

    namespace Id3dtouchar{

        __global__ void XIAOXING_CUDAKernel( cudaTextureObject_t text_intput, uchar4* output, int width, int height ){

            int thread_x = (int)blockIdx.x * (int)blockDim.x + (int)threadIdx.x;
            int y = (int)blockIdx.y * (int)blockDim.y + (int)threadIdx.y;
            int base_x = thread_x << 2;

            if (y>=height || base_x >= width)return;
            
            int row_offset = y * width;
            float fy = (float)y + 0.5f;

            if (base_x + 3 < width)
            {
                uchar4 p0 = tex2D<uchar4>(text_intput, (float)(base_x + 0) + 0.5f, fy);
                uchar4 p1 = tex2D<uchar4>(text_intput, (float)(base_x + 1) + 0.5f, fy);
                uchar4 p2 = tex2D<uchar4>(text_intput, (float)(base_x + 2) + 0.5f, fy);
                uchar4 p3 = tex2D<uchar4>(text_intput, (float)(base_x + 3) + 0.5f, fy);

                output[row_offset + base_x + 0] = channelswitch_fast(p0);
                output[row_offset + base_x + 1] = channelswitch_fast(p1);
                output[row_offset + base_x + 2] = channelswitch_fast(p2);
                output[row_offset + base_x + 3] = channelswitch_fast(p3);
                return;
            }

           #pragma unroll
            for (int i = 0; i < 4; i++)
            {
                int x = base_x + i;
                if (x < width)
                {
                    uchar4 p = tex2D<uchar4>(text_intput, (float)x + 0.5f, fy);
                    output[row_offset + x] = channelswitch_fast(p);
                }
            }

        }


        __device__ __forceinline__ static uchar4 channelswitch_fast(uchar4 v)
        {
            return make_uchar4(v.z, v.y, v.x, 255);
        }
    }
    // 下面这个核函数性能提升不大，如果需要优化建议改主路径采用更好的中间数据
    // namespace test{

    //     #ifndef USE_BYTE_PERM
    //     #define USE_BYTE_PERM 0
    //     #endif

    //     __device__ __forceinline__ static unsigned int channelswitch_u32(unsigned int v)
    //     {
    //     #if USE_BYTE_PERM
    //         // input bytes from x:
    //         // byte0 = B
    //         // byte1 = G
    //         // byte2 = R
    //         // byte3 = A
    //         //
    //         // target output:
    //         // byte0 = R (selector 2)
    //         // byte1 = G (selector 1)
    //         // byte2 = B (selector 0)
    //         // byte3 = 255 (selector 4 from y)
    //         //
    //         // y = 0x000000ff -> byte4 = 0xff
    //         return __byte_perm(v, 0x000000ffu, 0x4012);
    //     #else
    //         // output bytes:
    //         // byte0 = R
    //         // byte1 = G
    //         // byte2 = B
    //         // byte3 = 255
    //         return ((v & 0x00ff0000u) >> 16) |
    //             (v & 0x0000ff00u) |
    //             ((v & 0x000000ffu) << 16) |
    //             0xff000000u;
    //     #endif
    //     }

    //     // TextreObj 输入 输出uchar指针 图片宽,图片高
    //     __global__ void XIAOXING_CUDAKenel_test(cudaTextureObject_t text_input,uchar4* output,int width,int height)
    //     {
    //         int thread_x = (int)blockIdx.x * (int)blockDim.x + (int)threadIdx.x;
    //         int y = (int)blockIdx.y * (int)blockDim.y + (int)threadIdx.y;
    //         int base_x = thread_x << 2;

    //         if (y >= height || base_x >= width)
    //         {
    //             return;
    //         }

    //         int row_offset = y * width;
    //         float fy = (float)y + 0.5f;

    //         if (base_x + 3 < width)
    //         {
    //             uchar4 p0 = tex2D<uchar4>(text_input, (float)(base_x + 0) + 0.5f, fy);
    //             uchar4 p1 = tex2D<uchar4>(text_input, (float)(base_x + 1) + 0.5f, fy);
    //             uchar4 p2 = tex2D<uchar4>(text_input, (float)(base_x + 2) + 0.5f, fy);
    //             uchar4 p3 = tex2D<uchar4>(text_input, (float)(base_x + 3) + 0.5f, fy);

    //             unsigned int v0 =  channelswitch_u32(*((unsigned int*)&p0));
    //             unsigned int v1 =  channelswitch_u32(*((unsigned int*)&p1));
    //             unsigned int v2 =  channelswitch_u32(*((unsigned int*)&p2));
    //             unsigned int v3 =  channelswitch_u32(*((unsigned int*)&p3));

    //             uint4 packed;
    //             packed.x = v0;
    //             packed.y = v1;
    //             packed.z = v2;
    //             packed.w = v3;

    //             ((uint4*)(output + row_offset + base_x))[0] = packed;
    //             return;
    //         }

    //     #pragma unroll
    //         for (int i = 0; i < 4; i++)
    //         {
    //             int x = base_x + i;
    //             if (x < width)
    //             {
    //                 uchar4 p = tex2D<uchar4>(text_input, (float)x + 0.5f, fy);
    //                 unsigned int v =  channelswitch_u32(*((unsigned int*)&p));
    //                 output[row_offset + x] = *((uchar4*)&v);
    //             }
    //         }
    //     }
    // }

}




