// 裁剪
// 这里这做 ROI 的偏移 ，计算出新的起点xy，与宽高  需要始终保持原图片的宽高
#include "PIC_Cut_Size.cuh"
#include "ERROR.cuh"
#include "XIAOXING_CUDAkenel.cuh"

#include <cuda_runtime.h>
#include <stdexcept>


Pic_Cut_Size::Pic_Cut_Size() {
    shuchukuandu_output_w = 0;
    shuchugaodu_output_h = 0;
    shuchuqidianX_output_x = 0;
    shuchuqidianY_output_y = 0;
}

void Pic_Cut_Size::dispose() {

}

bool Pic_Cut_Size::xiaoxing_yingshequjian(float2 targetsize_w, float2 targetsize_h, int input_w, int input_h, int& start_x, int& start_y, int& width, int& height) {
    int start_x_temp = (int)(targetsize_w.x * input_w);
    int end_x_temp = (int)(targetsize_w.y * input_w);

    int start_y_temp = (int)(targetsize_h.x * input_h);
    int end_y_temp = (int)(targetsize_h.y * input_h);

    if (start_x_temp < 0) start_x_temp = 0;
    if (start_y_temp < 0) start_y_temp = 0;
    if (end_x_temp > input_w) end_x_temp = input_w;
    if (end_y_temp > input_h) end_y_temp = input_h;

    if (end_x_temp < start_x_temp) end_x_temp = start_x_temp;
    if (end_y_temp < start_y_temp) end_y_temp = start_y_temp;

    int width_temp = end_x_temp - start_x_temp;
    int height_temp = end_y_temp - start_y_temp;

    if (width_temp <= 0 || height_temp <= 0) {
        XIAOXING_CUSTOMERROR("CPU","Pic_Cut_Size"," 裁剪的图片小于0 ");
    }

    start_x = start_x_temp;
    start_y = start_y_temp;
    width = width_temp;
    height = height_temp;

    return true;
}

// 输入区间为 0-1 之间， 最后一个参数（宽度，高度）
void Pic_Cut_Size::xiaoxing_cudacutsize(
    uchar4*& fanhuiuchar4_backpoint,
    float2 targetsize_w,
    float2 targetsize_h,
    int2 yuantukuangao_originalpicturewidthhight
    
) {
    if (fanhuiuchar4_backpoint == nullptr) {
        XIAOXING_CUSTOMERROR("CPU","Pic_Cut_Size"," 输入指针是空的 ");
    }
    shuchukuandu_output_w = 0;
    shuchugaodu_output_h = 0;
    shuchuqidianX_output_x=0;
    shuchuqidianY_output_y=0;
    
    bool is_success = xiaoxing_yingshequjian(
        targetsize_w,
        targetsize_h,
        yuantukuangao_originalpicturewidthhight.x,
        yuantukuangao_originalpicturewidthhight.y,
        shuchuqidianX_output_x,
        shuchuqidianY_output_y,
        shuchukuandu_output_w,
        shuchugaodu_output_h
    );
    if (!is_success){

        XIAOXING_CUSTOMERROR("CPU","Pic_Cut_Size"," 裁剪失败 ");
    };

    fanhuiuchar4_backpoint = fanhuiuchar4_backpoint + 
        (size_t)shuchuqidianY_output_y * 
        (size_t)yuantukuangao_originalpicturewidthhight.x + 
        (size_t)shuchuqidianX_output_x;
}
