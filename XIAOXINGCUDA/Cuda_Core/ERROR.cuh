#pragma once
#include <cuda_runtime.h>
#include <nvjpeg.h>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>
#include <sstream>

#define XIAOXING_FILE_NAME "XIAOXING_CUDA.DLL"

#define XIAOXING_CHECK_CUDA(call, inmsg)                                          \
    do                                                                            \
    {                                                                             \
        const cudaError_t xiaoxing_cuda_err__ = (call);                           \
        if (xiaoxing_cuda_err__ != cudaSuccess)                                   \
        {                                                                         \
            std::ostringstream xiaoxing_cuda_oss__;                               \
            xiaoxing_cuda_oss__                                                   \
                << XIAOXING_FILE_NAME                                             \
                << " - 设备: GPU "                                                \
                << " - 错误文件: " << XIAOXING_FILE_NAME                          \
                << " - 开发者文件 " << __FILE__                                   \
                << " - 错误行号: " << __LINE__                                    \
                << " - 自定义信息: " << (inmsg)                                   \
                << " - CUDA底层: " << cudaGetErrorString(xiaoxing_cuda_err__)     \
                << " - CUDA错误码: " << static_cast<int>(xiaoxing_cuda_err__);    \
            throw std::runtime_error(xiaoxing_cuda_oss__.str());                  \
        }                                                                         \
    } while (0)                                                                    

#define XIAOXING_CHECK_NVJPEG(call, inmsg)                                        \
    do                                                                            \
    {                                                                             \
        const nvjpegStatus_t xiaoxing_nvjpeg_err__ = (call);                      \
        if (xiaoxing_nvjpeg_err__ != NVJPEG_STATUS_SUCCESS)                       \
        {                                                                         \
            std::ostringstream xiaoxing_nvjpeg_oss__;                             \
            xiaoxing_nvjpeg_oss__                                                 \
                << XIAOXING_FILE_NAME                                             \
                << " - 设备: GPU "                                                \
                << " - 错误文件: " << XIAOXING_FILE_NAME                          \
                << " - 开发者文件 " << __FILE__                                   \
                << " - 错误行号: " << __LINE__                                    \
                << " - 自定义信息: " << (inmsg)                                   \
                << " - NVJPEG底层: "                                              \
                << xiaoxing_nvjpeg_get_error_string(xiaoxing_nvjpeg_err__)        \
                << " - NVJPEG错误码: "                                            \
                << static_cast<int>(xiaoxing_nvjpeg_err__);                       \
            throw std::runtime_error(xiaoxing_nvjpeg_oss__.str());                \
        }                                                                         \
    } while (0)   
                                                                 

#define XIAOXING_Dispose_CUDAFree(ptr)                                         \
    do {                                                                       \
        if ((ptr) != nullptr) {                                                \
            XIAOXING_CHECK_CUDA(cudaFree(ptr)," 释放CUDA 资源失败 ");            \
            (ptr) = nullptr;                                                   \
        }                                                                      \
    } while (0)

#define XIAOXING_Dispose_CUDAFreeArray(ptr)                                    \
    do {                                                                       \
        if ((ptr) != nullptr) {                                                \
            XIAOXING_CHECK_CUDA(cudaFreeArray(ptr), " 释放CUDA 数组失败  ");    \
            (ptr) = nullptr;                                                   \
        }                                                                      \
    } while (0)


#define XIAOXING_Dispose_NVJPEGHandle(ptr)                                     \
    do {                                                                       \
        if ((ptr) != nullptr) {                                                \
            XIAOXING_CHECK_NVJPEG(nvjpegDestroy(ptr)," 释放NVJPEG 句柄失败 ");  \
            (ptr) = nullptr;                                                   \
        }                                                                      \
    } while (0)

inline const char* xiaoxing_nvjpeg_get_error_string(nvjpegStatus_t status)
{
    switch (status)
    {
    case NVJPEG_STATUS_SUCCESS:
        return "SUCCESS";
    case NVJPEG_STATUS_NOT_INITIALIZED:
        return "NOT_INITIALIZED";
    case NVJPEG_STATUS_INVALID_PARAMETER:
        return "INVALID_PARAMETER";
    case NVJPEG_STATUS_BAD_JPEG:
        return "BAD_JPEG";
    case NVJPEG_STATUS_JPEG_NOT_SUPPORTED:
        return "JPEG_NOT_SUPPORTED";
    case NVJPEG_STATUS_ALLOCATOR_FAILURE:
        return "ALLOCATOR_FAILURE";
    case NVJPEG_STATUS_EXECUTION_FAILED:
        return "EXECUTION_FAILED";
    case NVJPEG_STATUS_ARCH_MISMATCH:
        return "ARCH_MISMATCH";
    default:
        return "NVJPEG_UNKNOWN_OR_INTERNAL_ERROR";
    }
}
// 设备位置 文件名称 自定义信息
#define XIAOXING_CUSTOMERROR(device, filename, inmsg) \
    do                                                                              \
    {                                                                               \
        std::ostringstream xiaoxing_oss__;                                          \
        xiaoxing_oss__                                                              \
            << " 开发者文件: " << __LINE__                                          \
            <<XIAOXING_FILE_NAME                                                   \
            << " - 设备: " << (device)                                              \
            << " - 错误文件: " << (filename)                                        \
            << " - 错误行号: " << __LINE__                                          \
            << " - 自定义信息: " << (inmsg);                                         \
       throw std::runtime_error(xiaoxing_oss__.str());                             \
    } while (0)