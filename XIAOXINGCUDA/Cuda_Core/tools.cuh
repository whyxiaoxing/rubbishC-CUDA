#ifndef TOOLS_CUH
#define TOOLS_CUH

#include <cuda_runtime.h>
#include "ERROR.cuh"
// uchar* 宽度 高度 结果
#define XIAOXING_CUDA_Malloc(ptr, width, height, res) \
do { \
    size_t total_size = (size_t)(width) * (size_t)(height) * sizeof(uchar4); \
    cudaError_t err = cudaMalloc((void**)&(ptr), total_size); \
    if (err != cudaSuccess) { \
        (ptr) = nullptr; \
        (res) = false; \
        std::ostringstream xiaoxing_malloc_oss__; \
        xiaoxing_malloc_oss__ << "CUDA Malloc uchar4 失败" \
                              << " - width: " << (width) \
                              << " - height: " << (height) \
                              << " - total_size: " << total_size \
                              << " - CUDA底层: " << cudaGetErrorString(err); \
        XIAOXING_CUSTOMERROR("GPU", XIAOXING_FILE_NAME, xiaoxing_malloc_oss__.str()); \
    } else { \
        (res) = true; \
    } \
} while(0)

// float* 宽度 高度 结果
#define XIAOXING_CUDA_Malloc_PPOCRFloat(ptr, width, height, res) \
do { \
    size_t total_size = (size_t)(width) * (size_t)(height) * (size_t)3 * sizeof(float); \
    cudaError_t err = cudaMalloc((void**)&(ptr), total_size); \
    if (err != cudaSuccess) { \
        (ptr) = nullptr; \
        (res) = false; \
        std::ostringstream xiaoxing_malloc_oss__; \
        xiaoxing_malloc_oss__ << " CUDA Malloc PPOCR float NCHW 失败 " \
                              << " - width: " << (width) \
                              << " - height: " << (height) \
                              << " - channel: 3" \
                              << " - total_size: " << total_size \
                              << " - CUDA底层: " << cudaGetErrorString(err); \
        XIAOXING_CUSTOMERROR("GPU", XIAOXING_FILE_NAME, xiaoxing_malloc_oss__.str()); \
    } else { \
        (res) = true; \
    } \
} while(0)

#endif
