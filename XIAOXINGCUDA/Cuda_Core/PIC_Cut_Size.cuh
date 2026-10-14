#ifndef PIC_CUT_SIZE_CUH
#define PIC_CUT_SIZE_CUH

#include <cuda_runtime.h>
// ROI 裁剪， 直接叠加到 导入的指针
class Pic_Cut_Size
{
private:
    
    bool xiaoxing_yingshequjian(float2 targetsize_w, float2 targetsize_h, int input_w, int input_h, int& start_x, int& start_y, int& width, int& height);
    int shuchuqidianX_output_x;
    int shuchuqidianY_output_y;

public:
    int shuchukuandu_output_w;
    int shuchugaodu_output_h;
    

    Pic_Cut_Size();
    Pic_Cut_Size(const Pic_Cut_Size&) = delete;
    Pic_Cut_Size& operator=(const Pic_Cut_Size&) = delete;

    void dispose();
    void xiaoxing_cudacutsize(
        uchar4*& fanhuiuchar4_backpoint, // 这里直接修改外部的值
        float2 targetsize_w,
        float2 targetsize_h,
        int2 yuantukuangao_originalpicturewidthhight
    );
};

#endif
