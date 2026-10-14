#ifndef FOUND_F_SOURCECODE_CUH
#define FOUND_F_SOURCECODE_CUH

#include "PIC_Cut_Size.cuh"
#include<cuda_runtime.h>
#include<npp.h>

class Found_F_SourceCode
{
private:
    
    Npp8u* huiduzhizhen_outgray;
    uchar4* daichulixianc_need_found_F;
    int* f_found_flags;
    int fdaxiao_fsize;
    int* f_top_y;
    int* f_top_x;
    int kuandu;
    int gaodu;
    int saomiaoquyu;
    //F区域
    int f_huisezhi_blackvale;
    int f_baisezhi_whitevale;
    int f_yansewucha_coloerdeviation;
    int f_zuocejianchaxiangsu_leftcheck;
    int f_dingbujianchadibujianchaxiangsu_topandbottomcheck;
    unsigned int  suanzi_threshold;

public:

    
    int shuchukuandu_output_w;
    int shuchugaodu_output_h;
    Found_F_SourceCode(int _k=480, int _g = 70, int _b=80);
    Found_F_SourceCode(const Found_F_SourceCode&) = delete;
    Found_F_SourceCode& operator=(const Found_F_SourceCode&) = delete;

    void dispose();
    bool xiaoxing_Found_F(
        uchar4*& _InputCudaArray,
        int width,
        int height,
        int2 yuantukuangao_originalpicturewidthhight,
        cudaStream_t stream = 0
    );

};


#endif

