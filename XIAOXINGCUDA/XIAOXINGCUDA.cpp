#include <stdio.h>
#include "WGC_DLL/Data_One.h"

int main() {

	DataClass_One WGC_DLL;

	if (WGC_DLL.CheckUserDeviceSupportWGC()) {

		printf("检查通过");

	}
	else
	{
		printf("不支持DLL");
		return 1;
	}
	try{
		auto WinRtActivateObj = WGC_DLL.GetMoitorSerial();

		auto D3DDevice = WGC_DLL.FromHmonitorFindToIdirect3ddevice();

		WGC_DLL.CreateD3DFramePool(D3DDevice, WinRtActivateObj);

		int a = 0;
		while(a<10){
			
			
			auto b = [&] {
				std::lock_guard<std::mutex> lock(WGC_DLL.FrameLock);
				return WGC_DLL.GetFrame;   // 返回拷贝
				}();
			b = nullptr;
			a++;
			printf("取帧成功");
		
		}

	}
	catch (winrt::hresult_error const& ex){

		// hresult_error 不继承 std::exception，必须单独接；
		// message() 是 hstring（宽字符），只能用 wprintf
		printf("WinRT 错误: 0x%08X\n", static_cast<unsigned int>(ex.code()));
		wprintf(L"%s\n", ex.message().c_str());

	}
	catch (std::exception const& ex){

		printf("%s\n", ex.what());

	}


	

	
}
