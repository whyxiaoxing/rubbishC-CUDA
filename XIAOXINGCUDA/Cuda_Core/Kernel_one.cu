#include "XIAOXING_CUDAkenel.cuh"
#include <cuda_runtime.h>


namespace CUDAKernel_one {

namespace Kernel_qu_se_qi {


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
) {
    
    int x = blockIdx.x * blockDim.x + threadIdx.x + x_start;
    if (x >= x_end || x >= width)return;

    f_found_flags[x] = 0;
    f_top_y[x] = -1;
    f_top_x[x] = -1;

    int y_top = xiaoxing_find_maybe_f(

        input,
        input_origPic_width,
        width,
        x,
        height,
        f_huisezhi_blackvale,
        f_baisezhi_whitevale,
        f_yansewucha_coloerdeviation,
        f_zuocejianchaxiangsu_leftcheck,
        f_dingbujianhedibujianchaxiangsu_topandbottomcheck,
        f_jiancegaodu_fhight
    );

    if (y_top >=0)
    {
        f_found_flags[x] = 1;
        f_top_y[x] = y_top;
        f_top_x[x] = x;
    }
    

}



__global__ void XIAOXING_CUDAKenel2(
    int x_start, 
    int x_end, 
    int *f_found_flags, 
    int *f_top_y, 
    int *f_top_x
){
     __shared__ int xianchengfaxianzuihaox_threadfoundx[256];
     __shared__ int xianchengfaxianzuihaoy_threadfoundy[256];

     const int xiancheng_tid = (int)threadIdx.x;
     int zuihaox_bestx= -1;
     int zuihaox_besty = -1;
     
   for (int x = x_start + threadIdx.x; x < x_end; x += blockDim.x)

     {
        if (f_found_flags[x] == 1 && f_top_x[x] >= 0 && f_top_y[x] >= 0) {
            zuihaox_bestx = f_top_x[x];
            zuihaox_besty = f_top_y[x];
            break;
        }
     }

     xianchengfaxianzuihaox_threadfoundx[xiancheng_tid] = zuihaox_bestx;
     xianchengfaxianzuihaoy_threadfoundy[xiancheng_tid] = zuihaox_besty;
     __syncthreads();

     for (int strdie = (int)blockDim.x >>1; strdie > 0; strdie>>=1) // 这里用了个规约 + 二分  请不要动此处代码，AI写的未知
     {
        if (xiancheng_tid < strdie)
        {
            const int right_x = xianchengfaxianzuihaox_threadfoundx[xiancheng_tid + strdie];
            if (right_x >=0 && (xianchengfaxianzuihaox_threadfoundx[xiancheng_tid] <0 || right_x < xianchengfaxianzuihaox_threadfoundx[xiancheng_tid] ))
            {
                xianchengfaxianzuihaox_threadfoundx[xiancheng_tid] = right_x;
                xianchengfaxianzuihaoy_threadfoundy[xiancheng_tid] = xianchengfaxianzuihaoy_threadfoundy[xiancheng_tid + strdie];
            }
            
        }
        __syncthreads();   
     }
     if (xiancheng_tid == 0 )
     {
        const int found = xianchengfaxianzuihaox_threadfoundx[0] >= 0 ? 1 : 0;
        f_found_flags[0] = found;
        f_top_x[0] = found ? xianchengfaxianzuihaox_threadfoundx[0] : -1;
        f_top_y[0] = found ? xianchengfaxianzuihaoy_threadfoundy[0] : -1;
     }
     
}

__device__ __forceinline__ static int xiaoxing_is_black_pixel(uchar4 p, int black,int deviation)
{
    int r = (int)p.x;
    int g = (int)p.y;
    int b = (int)p.z;
    // 采用加权平均的办法(小数点后3位) 对比黑色权重
    int lower = xiaoxing_clamp_to_byte(black - deviation);
    int upper = xiaoxing_clamp_to_byte(black + deviation);

    return (r >= lower && r <= upper &&
            g >= lower && g <= upper &&
            b >= lower && b <= upper);
}

__device__ __forceinline__ static int xiaoxing_is_white_pixel(
    uchar4 p,
    int white,
    int deviation
) {
    int r = (int)p.x;
    int g = (int)p.y;
    int b = (int)p.z;
    // 白色判断与黑色一致
    int lower = xiaoxing_clamp_to_byte(white - deviation);
    int upper = xiaoxing_clamp_to_byte(white + deviation);

    return (r >= lower && r <= upper &&
            g >= lower && g <= upper &&
            b >= lower && b <= upper);
}

__device__ __forceinline__ static int xiaoxing_clamp_to_byte(int value) {
    if (value < 0) return 0;
    if (value > 255) return 255;
    return value;
}


 __device__ __forceinline__ int xiaoxing_find_maybe_f(
    uchar4 *input,
    int input_origPic_width,
    int width,
    int x, 
    int height, 
    int f_huisezhi_blackvale, 
    int f_baisezhi_whitevale, 
    int f_yansewucha_coloerdeviation, 
    int f_zuocejianchaxiangsu_leftcheck, 
    int f_dingbujianhedibujianchaxiangsu_topandbottomcheck, 
    int f_jiancegaodu_fhight) 
    {
     
        int zuocezuixiaozhi_leftminx = max(0, x - f_zuocejianchaxiangsu_leftcheck);
        const int yzuidaqishizhi_ymaxstart = height - f_jiancegaodu_fhight; // 常量优化，for循环用到
        int y = 0;

        while (y <= yzuidaqishizhi_ymaxstart)
        {
            uchar4* input_row = input + (size_t)y * (size_t)input_origPic_width;
            if (!xiaoxing_is_black_pixel(
                    input_row[x],
                    f_huisezhi_blackvale,
                    f_yansewucha_coloerdeviation
                )) {
                y++;
                continue;
            }

            const int y_top = y;
            int y_bottom = y_top;

            for (int next_y = y_top + 1; next_y < height; next_y++)
            {
                input_row = input + (size_t)next_y * (size_t)input_origPic_width;
                if (!xiaoxing_is_black_pixel(
                        input_row[x],
                        f_huisezhi_blackvale,
                        f_yansewucha_coloerdeviation
                    )) {
                    break;
                }

                y_bottom = next_y;
            }
            y = y_bottom + 1;

            const int h = y_bottom - y_top + 1;
            if (h<f_jiancegaodu_fhight)continue; // 小于F 设定高度直接下一个 
            
            const int y0 = y_top + h / 5;
            const int y1 = y_top + h * 2 / 5;
            const int y2 = y_top + h * 3 / 5;
            const int y3 = y_top + h * 4 / 5;

            uchar4* row0 = input + (size_t)y0 * (size_t)input_origPic_width;
            uchar4* row1 = input + (size_t)y1 * (size_t)input_origPic_width;
            uchar4* row2 = input + (size_t)y2 * (size_t)input_origPic_width;
            uchar4* row3 = input + (size_t)y3 * (size_t)input_origPic_width;

            if (!(xiaoxing_is_black_pixel(row0[x], f_huisezhi_blackvale, f_yansewucha_coloerdeviation) &&
                  xiaoxing_is_black_pixel(row1[x], f_huisezhi_blackvale, f_yansewucha_coloerdeviation) &&
                  xiaoxing_is_black_pixel(row2[x], f_huisezhi_blackvale, f_yansewucha_coloerdeviation) &&
                  xiaoxing_is_black_pixel(row3[x], f_huisezhi_blackvale, f_yansewucha_coloerdeviation))) {
                continue;
            }

            int ok = 1;
            const int ys[4] = { y0, y1, y2, y3 };
#pragma unroll
            for (int i = 0; i < 4; i++){

                const int y = ys[i];
                int has_white = 0;
                uchar4* row = input + (size_t)y * (size_t)input_origPic_width;
                int tail_start_x = x - 1;

                for (; tail_start_x - 4 >= zuocezuixiaozhi_leftminx; tail_start_x -= 5)
                {
                    const int group_left_x1 = tail_start_x;
                    const int group_left_x3 = tail_start_x - 2;
                    const int group_left_x5 = tail_start_x - 4;

                    int white_count = 0;
                    if (xiaoxing_is_white_pixel(row[group_left_x1], f_baisezhi_whitevale, f_yansewucha_coloerdeviation)) white_count++;
                    if (xiaoxing_is_white_pixel(row[group_left_x3], f_baisezhi_whitevale, f_yansewucha_coloerdeviation)) white_count++;
                    if (xiaoxing_is_white_pixel(row[group_left_x5], f_baisezhi_whitevale, f_yansewucha_coloerdeviation)) white_count++;

                    if (white_count >= 2)
                    {
                        has_white = 1;
                        break;
                    }
                }

                if (!has_white && tail_start_x >= zuocezuixiaozhi_leftminx)
                {
                    int all_white = 1;
                    for (int lx = tail_start_x; lx >= zuocezuixiaozhi_leftminx; lx--)
                    {
                        if (!xiaoxing_is_white_pixel(row[lx], f_baisezhi_whitevale, f_yansewucha_coloerdeviation))
                        {
                            all_white = 0;
                            break;
                        }
                    }

                    if (all_white)
                    {
                        has_white = 1;
                    }
                }
                
                if (!has_white) {
                    ok = 0;
                    break;
                }
            }

            if (!ok)continue;
            
            int has_top_white = 0;
            int has_bottom_white = 0;

            int top_begin = max(0, y_top - f_dingbujianhedibujianchaxiangsu_topandbottomcheck);

            int bottom_end = min(height - 1, y_bottom + f_dingbujianhedibujianchaxiangsu_topandbottomcheck);

            for (int ty = y_top - 1; ty >= top_begin; ty--) {
                uchar4* row = input + (size_t)ty * (size_t)input_origPic_width;
                if (xiaoxing_is_white_pixel(
                        row[x],
                        f_baisezhi_whitevale,
                        f_yansewucha_coloerdeviation
                    )) {
                    has_top_white = 1;
                    break;
                }
            }
            
            for (int by = y_bottom + 1; by <= bottom_end; by++) {
                uchar4* row = input + (size_t)by * (size_t)input_origPic_width;
                if (xiaoxing_is_white_pixel(
                        row[x],
                        f_baisezhi_whitevale,
                        f_yansewucha_coloerdeviation
                    )) {
                    has_bottom_white = 1;
                    break;
                }
            }

            if (has_top_white && has_bottom_white) {
                return y_top;
            }

        }
        return -1;
        

}

}  

}  

namespace CUDAKernel_three{

    namespace to_chw{
        
        // 输入原图像指针,输出目标的指针,输入宽度,输入高度,目标高度=128 
        __global__ void XIAOXING_CUDAKenel(uchar4*  __restrict__ input,float*  __restrict__ output,int inputwidth,int inputhight ,int targetheight)
        {
            int x = (int)blockIdx.x * (int)blockDim.x + (int)threadIdx.x;
            int y = (int)blockIdx.y * (int)blockDim.y + (int)threadIdx.y;

            if (x >= inputwidth || y >= targetheight)
            {
            return;
            }

            const size_t output_index = (size_t)y * (size_t)inputwidth + (size_t)x;
            const size_t channel_size = (size_t)inputwidth * (size_t)targetheight;

            const float inv_scale = 1.0f / 127.5f;
            const float pad_val = 144.0f * inv_scale - 1.0f;

            float r = pad_val;
            float g = pad_val;
            float b = pad_val;


            if (y < inputhight)
            {
                uchar4 pixel = input[output_index];

                b = (float)pixel.x * inv_scale - 1.0f;
                g = (float)pixel.y * inv_scale - 1.0f;
                r = (float)pixel.z * inv_scale - 1.0f;
            }
            else
            {
                r = pad_val;
                g = pad_val;
                b = pad_val;
            }

            output[output_index] = r;
            output[channel_size + output_index] = g;
            output[channel_size + channel_size + output_index] = b;
        }

    }
}
