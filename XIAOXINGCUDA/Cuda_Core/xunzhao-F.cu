#include "Found_F_SourceCode.cuh"
#include "XIAOXING_CUDAkenel.cuh"
#include "ERROR.cuh"

#include <stdio.h>
#include <stdexcept>

void Found_F_SourceCode::dispose() {
    XIAOXING_Dispose_CUDAFree(huiduzhizhen_outgray);
    XIAOXING_Dispose_CUDAFree(daichulixianc_need_found_F);
    XIAOXING_Dispose_CUDAFree(f_found_flags);
    XIAOXING_Dispose_CUDAFree(f_top_y);
    XIAOXING_Dispose_CUDAFree(f_top_x);
    fdaxiao_fsize = 0;
    shuchukuandu_output_w = 0;
    shuchugaodu_output_h = 0;

}

Found_F_SourceCode::Found_F_SourceCode(int _k, int _g, int _b) {
    huiduzhizhen_outgray = nullptr;
    daichulixianc_need_found_F = nullptr;
    f_found_flags = nullptr;
    f_top_y = nullptr;
    f_top_x = nullptr;
    fdaxiao_fsize = 0;
    kuandu=_k;
    gaodu=_g;
    saomiaoquyu=_b;
    f_huisezhi_blackvale = 40;
    f_baisezhi_whitevale = 250;
    f_yansewucha_coloerdeviation = 40;
    f_zuocejianchaxiangsu_leftcheck = 5;
    f_dingbujianchadibujianchaxiangsu_topandbottomcheck = 4;
    suanzi_threshold=0;

    shuchukuandu_output_w = 0;
    shuchugaodu_output_h = 0;

    const size_t found_f_buffer_bytes = 64ull * 1024ull * 1024ull;
    const int fixed_found_f_capacity =
    static_cast<int>(found_f_buffer_bytes / (sizeof(int) * 3ull));
    
    XIAOXING_CHECK_CUDA(cudaMallocManaged(
        (void**)&f_found_flags,
        static_cast<size_t>(fixed_found_f_capacity) * sizeof(int)
    ), " 在分配F字符的显存上发生不可预测的错误 ");
    XIAOXING_CHECK_CUDA(cudaMallocManaged(
        (void**)&f_top_y,
        static_cast<size_t>(fixed_found_f_capacity) * sizeof(int)
    ), " 在分配F字符的显存上发生不可预测的错误 ");
    XIAOXING_CHECK_CUDA(cudaMallocManaged(
        (void**)&f_top_x,
        static_cast<size_t>(fixed_found_f_capacity) * sizeof(int)
    ), " 在分配F字符的显存上发生不可预测的错误 ");
    fdaxiao_fsize = fixed_found_f_capacity;
}


// 输入图像指针 ，宽度，高度，cuda流，原始图像宽高(没有裁剪的)
bool Found_F_SourceCode::xiaoxing_Found_F(
    uchar4*& _InputCudaArray,
    int width,
    int height,
    int2 yuantukuangao_originalpicturewidthhight,
    cudaStream_t stream
    
) {
    if (_InputCudaArray == nullptr) {
        XIAOXING_CUSTOMERROR("CPU","xunzhao-F.cu"," 导入的uchar4指针是空的 ");
    }

    if (width <= 0 || height <= 0) {
        XIAOXING_CUSTOMERROR("CPU","xunzhao-F.cu"," 非预期的图像尺寸,图像尺寸的某一边小于0 ");
    }
    // 防止输入的图片， 大于预分配的 F特征容量
    if (width > fdaxiao_fsize) {
        XIAOXING_CUSTOMERROR("CPU","xunzhao-F.cu"," 图像的显存大小 大于预分配的显存,如果可以手动调整显存分配 ");
    }
   
    const int input_origPic_width =
        (yuantukuangao_originalpicturewidthhight.x > 0)
            ? yuantukuangao_originalpicturewidthhight.x
            : width;
  
 
    dim3 block(256);
    dim3 grid(
        static_cast<unsigned int>(( saomiaoquyu + static_cast<int>(block.x) - 1) / static_cast<int>(block.x))
    );
    CUDAKernel_one::Kernel_qu_se_qi::XIAOXING_CUDAKenel<<<grid, block,0,stream>>>(
        _InputCudaArray,
        input_origPic_width,
        width,
        height,
        0,
        saomiaoquyu,
        f_huisezhi_blackvale,
        f_baisezhi_whitevale,
        f_yansewucha_coloerdeviation,
        f_zuocejianchaxiangsu_leftcheck,
        f_dingbujianchadibujianchaxiangsu_topandbottomcheck,
        21,
        f_found_flags,
        f_top_y,
        f_top_x
    );
    
    CUDAKernel_one::Kernel_qu_se_qi::XIAOXING_CUDAKenel2<<<1,256,0,stream>>>(
        0,
        saomiaoquyu,
        f_found_flags,
        f_top_y,
        f_top_x
    );
    XIAOXING_CHECK_CUDA(cudaGetLastError()," CUDA核发生了计算错误,可能是参数溢出或者数组越界,位于xunzhao-F.cu ");
    XIAOXING_CHECK_CUDA(cudaStreamSynchronize(stream), " 在等待CUDA核结束时候发生了未知错误 "); // 不能省去，一个扫描代表必须处理一个结果
  

    if (f_found_flags[0] == 0 || f_top_x[0] < 0 || f_top_y[0] < 0) {
        
        return false;
    }

    int roi_x = f_top_x[0] + 40; // 控制裁剪起点
    int roi_y = f_top_y[0] - 15; // 控制裁剪起点

    
    // 设置高度 需要动态调整
    int roi_w=kuandu;
    int roi_h=gaodu; 

    roi_w=roi_w-6; // 控制裁剪宽度
    
    if (roi_x >= width || roi_y >= height) {
        XIAOXING_CUSTOMERROR("GPU","xunzhao-F.cu"," ROI裁剪的位置,不是预期得到的尺寸 ");
    }
    if (roi_x + roi_w > width) roi_w = width - roi_x;
    if (roi_y + roi_h > height) roi_h = height - roi_y;

    if (roi_w <= 0 || roi_h <= 0)
    {
        XIAOXING_CUSTOMERROR("GPU","xunzhao-F.cu"," ROI裁剪的算法出现错误,非预期范围 ");
    }

    _InputCudaArray=_InputCudaArray+
    (size_t)roi_y * 
    (size_t)input_origPic_width +
    (size_t)roi_x; 
    shuchukuandu_output_w = roi_w;
    shuchugaodu_output_h = roi_h;
    return true;
    
}
