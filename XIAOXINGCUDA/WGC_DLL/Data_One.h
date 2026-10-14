#pragma once
#include "pch.h"

using namespace winrt::Windows::Graphics::Capture;
using namespace winrt::Windows::Graphics::DirectX;
using namespace winrt::Windows::Graphics::DirectX::Direct3D11;

#ifdef WGCDLL_EXPORTS
#define WGC_API __declspec(dllexport)
#else
#define WGC_API __declspec(dllimport)
#endif

class WGC_API DataClass_One
{
	public:
		DataClass_One();
		DataClass_One(const DataClass_One&) = delete;
		DataClass_One& operator=(const DataClass_One) = delete;
		~DataClass_One();

		// 返回NULL是正常情况  | 这是检查是否支持WGC截图
		bool CheckUserDeviceSupportWGC();

		// 获取用户显示器 | 导入列表序列 自动选择 这里只返回 WinRT的激活后对象  
		GraphicsCaptureItem GetMoitorSerial(int xiabiao = 0);

		// 创建D3D11帧池  device：WinRT 设备  WinRTActivateObj：WinRT激活后的对象   PixelForamat：图片格式  需要给到的是  DirectXPixelFormat空间下的
		// 注意：WGC 只支持 B8G8R8A8UIntNormalized 和 R16G16B16A16Float 两种，传别的（比如 R8G8B8A8UInt）会抛 E_INVALIDARG
		void CreateD3DFramePool(IDirect3DDevice  device, GraphicsCaptureItem  WinRTActivateObj, DirectXPixelFormat PixelForamat = DirectXPixelFormat::B8G8R8A8UIntNormalized);

		// 从当前筛选的显示器 创建Id3ddevice
		IDirect3DDevice FromHmonitorFindToIdirect3ddevice();


		Direct3D11CaptureFrame GetFrame{ nullptr };

		std::mutex FrameLock;



	private:

		// WGC 帧池
		Direct3D11CaptureFramePool WGC_Frame_Pool{ nullptr };

		// 采集会话：必须作为成员持有，局部变量一析构采集就停了
		GraphicsCaptureSession WGC_Capture_Session{ nullptr };

		// 筛选出来的显示器
		HMONITOR Now_Hmoitor_Device{ nullptr };

		// 帧到达事件（自动复位，初始无信号）：FrameArrived 回调里 SetEvent
		HANDLE FrameArrivedEvent = CreateEventW(nullptr, FALSE, FALSE, nullptr);
		

		void FrameArrived_CallFunction(winrt::Windows::Graphics::Capture::Direct3D11CaptureFramePool const& sender);
};




