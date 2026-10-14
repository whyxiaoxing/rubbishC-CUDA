// cudaarray to jpg

#include "supper_the_test.cuh"
#include "ERROR.cuh"

#include <cuda_runtime.h>
#include <nvjpeg.h>
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <string>
#include <vector>

static __global__ void XIAOXING_CUDAkenel_RGBA_to_RGB_(
    const uchar4* shuru_rgba,
    size_t shuru_pitch,
    uchar4* shuchu_rgba,
    unsigned char* shuchu_rgb,
    int kuandu,
    int gaodu
) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= kuandu || y >= gaodu) {
        return;
    }

    const uchar4* row_rgba =
        (const uchar4*)((const char*)shuru_rgba + y * shuru_pitch);

    uchar4 pix = row_rgba[x];
    size_t output_idx = static_cast<size_t>(y) * static_cast<size_t>(kuandu) + static_cast<size_t>(x);
    shuchu_rgba[output_idx] = pix;

    size_t idx = output_idx * 3;
    shuchu_rgb[idx + 0] = pix.x;
    shuchu_rgb[idx + 1] = pix.y;
    shuchu_rgb[idx + 2] = pix.z;
}


CudaArray_TO_JPG::CudaArray_TO_JPG() {
    zhizhen_rgb = nullptr;
    zhizhen_rgba = nullptr;
    jpgjubing_handle = nullptr;
    jpgbianmaqianzhuangtai_jpegStast = nullptr;
    jpegbianmaqiPar_jpegParams = nullptr;
}

void CudaArray_TO_JPG::dispsoe() {
    if (jpgbianmaqianzhuangtai_jpegStast) {
        XIAOXING_CHECK_NVJPEG(
            nvjpegEncoderStateDestroy(jpgbianmaqianzhuangtai_jpegStast)," GPU: 在释放编码资源时候出现了问题 "
        );
        jpgbianmaqianzhuangtai_jpegStast = nullptr;
    }
    if (jpegbianmaqiPar_jpegParams) {
        XIAOXING_CHECK_NVJPEG(
            nvjpegEncoderParamsDestroy(jpegbianmaqiPar_jpegParams)," GPU: 在释放编码资源时候出现了问题 "
        );
        jpegbianmaqiPar_jpegParams = nullptr;
    }

    XIAOXING_Dispose_NVJPEGHandle(jpgjubing_handle);
    XIAOXING_Dispose_CUDAFree(zhizhen_rgba);
    XIAOXING_Dispose_CUDAFree(zhizhen_rgb);
}

void CudaArray_TO_JPG::xiaoxing_cudaarray_to_jpg(
    int kuandu,
    int gaodu,
    uchar4* shuru_rgba,
    const char* jpg_path,
    size_t shuru_pitch_bytes
) {
    try {
        if (kuandu <= 0 || gaodu <= 0 || shuru_rgba == nullptr || jpg_path == nullptr) {
            XIAOXING_CUSTOMERROR("CPU","CudaArray_To_JPG","导出JPG参数无效");
        }

        dispsoe();

        const uchar4* shuru_rgba_ptr = reinterpret_cast<const uchar4*>(shuru_rgba);
        size_t pitch_rgba = shuru_pitch_bytes;
        if (pitch_rgba == 0) {
            pitch_rgba = static_cast<size_t>(kuandu) * sizeof(uchar4);
        }

        XIAOXING_CHECK_CUDA(cudaMalloc(
            (void**)&zhizhen_rgba,
            static_cast<size_t>(kuandu) * static_cast<size_t>(gaodu) * sizeof(uchar4)
        )," GPU:在分配紧凑RGBA显存上出现了问题 ");

        XIAOXING_CHECK_CUDA(cudaMalloc(
            (void**)&zhizhen_rgb,
            static_cast<size_t>(kuandu) * static_cast<size_t>(gaodu) * 3
        )," GPU:在分配紧凑RGB显存上出现了问题 ");

        dim3 block(16, 16);
        dim3 grid(
            (kuandu + 15) / 16,
            (gaodu + 15) / 16
        );

        XIAOXING_CUDAkenel_RGBA_to_RGB_<<<grid, block>>>(
            shuru_rgba_ptr,
            pitch_rgba,
            zhizhen_rgba,
            zhizhen_rgb,
            kuandu,
            gaodu
        );
        XIAOXING_CHECK_CUDA(cudaGetLastError()," GPU 核函数运行出现错误,位于CudaArray_To_JPG.cu ");
        XIAOXING_CHECK_CUDA(cudaDeviceSynchronize()," CPU: 同步CUDA设备时出现问题 ");

        XIAOXING_CHECK_NVJPEG(nvjpegCreateSimple(&jpgjubing_handle)," GPU: 创建nvJPEG简易句柄时出现问题 ");
        XIAOXING_CHECK_NVJPEG(
            nvjpegEncoderStateCreate(
                jpgjubing_handle,
                &jpgbianmaqianzhuangtai_jpegStast,
                NULL
            )," GPU: 创建JPEG编码器状态时出现问题 "
        );
        XIAOXING_CHECK_NVJPEG(
            nvjpegEncoderParamsCreate(
                jpgjubing_handle,
                &jpegbianmaqiPar_jpegParams,
                NULL
            )," GPU: 创建JPEG编码器参数时出现问题 "
        );

        XIAOXING_CHECK_NVJPEG(
            nvjpegEncoderParamsSetQuality(jpegbianmaqiPar_jpegParams, 90, 0)," GPU: 设置JPEG编码质量参数时出现问题 "
        );
        XIAOXING_CHECK_NVJPEG(
            nvjpegEncoderParamsSetEncoding(
                jpegbianmaqiPar_jpegParams,
                NVJPEG_ENCODING_BASELINE_DCT,
                NULL
            )," GPU: 设置JPEG编码类型时出现问题 "
        );
        XIAOXING_CHECK_NVJPEG(
            nvjpegEncoderParamsSetSamplingFactors(
                jpegbianmaqiPar_jpegParams,
                NVJPEG_CSS_444,
                NULL
            )," GPU: 设置JPEG采样因子时出现问题 "
        );
        XIAOXING_CHECK_NVJPEG(
            nvjpegEncoderParamsSetOptimizedHuffman(
                jpegbianmaqiPar_jpegParams,
                1,
                NULL
            )," GPU: 设置JPEG优化霍夫曼编码时出现问题 "
        );

        nvjpegImage_t zuihoutupian;
        std::memset(&zuihoutupian, 0, sizeof(zuihoutupian));
        zuihoutupian.channel[0] = zhizhen_rgb;
        zuihoutupian.pitch[0] = static_cast<size_t>(kuandu) * 3;

        XIAOXING_CHECK_NVJPEG(nvjpegEncodeImage(
            jpgjubing_handle,
            jpgbianmaqianzhuangtai_jpegStast,
            jpegbianmaqiPar_jpegParams,
            &zuihoutupian,
            NVJPEG_INPUT_RGBI,
            kuandu,
            gaodu,
            NULL
        )," GPU: 在编码图片时候出现问题 ");

        size_t changdu_length = 0;
        XIAOXING_CHECK_NVJPEG(nvjpegEncodeRetrieveBitstream(
            jpgjubing_handle,
            jpgbianmaqianzhuangtai_jpegStast,
            NULL,
            &changdu_length,
            NULL
        )," 出现了问题,卧槽我不想写了 ");

        std::vector<unsigned char> jpeg_data(changdu_length);
        XIAOXING_CHECK_NVJPEG(nvjpegEncodeRetrieveBitstream(
            jpgjubing_handle,
            jpgbianmaqianzhuangtai_jpegStast,
            jpeg_data.data(),
            &changdu_length,
            NULL
        )," 出现了问题不知道怎么描述,太难了 ");

        FILE* f = fopen(jpg_path, "wb");
       
        size_t written = fwrite(jpeg_data.data(), 1, changdu_length, f);
        if (written != changdu_length) {
            fclose(f);
            XIAOXING_CUSTOMERROR(" CPU "," CudaArray_To_JPG "," 写入JPG文件不完整 ");
        }
        int a=fclose(f);
        if (a==0)
        {
        
        }else{

           XIAOXING_CUSTOMERROR(" CPU "," CudaArray_To_JPG "," 无法释放写入句柄 ");
        }

        f=nullptr;
        
    }
    catch (const std::exception& e) {
        throw;
    }
}
