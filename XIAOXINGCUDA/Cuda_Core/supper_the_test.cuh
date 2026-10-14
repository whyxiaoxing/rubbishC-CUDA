#ifndef SUPPER_THE_TEST_CUH
#define SUPPER_THE_TEST_CUH
#include <cuda_runtime.h>
#include <nvjpeg.h>

using uchar = unsigned char;


class CudaArray_TO_JPG
{
private:
    uchar4* zhizhen_rgba;
    unsigned char* zhizhen_rgb;
    nvjpegHandle_t jpgjubing_handle;
    nvjpegEncoderState_t jpgbianmaqianzhuangtai_jpegStast;
    nvjpegEncoderParams_t jpegbianmaqiPar_jpegParams;

public:
    CudaArray_TO_JPG();
    CudaArray_TO_JPG(const CudaArray_TO_JPG&) = delete;
    CudaArray_TO_JPG& operator=(const CudaArray_TO_JPG&) = delete;
 

    void dispsoe();
    void xiaoxing_cudaarray_to_jpg(
        int kuandu,
        int gaodu,
        uchar4* shuru_rgba,
        const char* jpg_path,
        size_t shuru_pitch_bytes = 0
    );
};

#endif
