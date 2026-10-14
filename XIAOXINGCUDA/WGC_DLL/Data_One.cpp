#include "pch.h"
#include "Data_One.h"

#include <d3d11.h>
#include <dxgi1_2.h>

using namespace winrt::Windows::Graphics::DirectX::Direct3D11;
using namespace winrt::Windows::Graphics::DirectX;
using namespace winrt::Windows::Graphics::Capture;
using namespace winrt::Windows::Graphics::DirectX;
using namespace winrt::Windows::Graphics;
using namespace winrt;



// 结构体定义
struct MonitorInfo
{
    MonitorInfo(HMONITOR monitorHandle)
    {
        MonitorHandle = monitorHandle;
        MONITORINFOEX monitorInfo = { sizeof(monitorInfo) };
        winrt::check_bool(GetMonitorInfo(MonitorHandle, &monitorInfo));
        std::wstring displayName(monitorInfo.szDevice);
        DisplayName = displayName;
    }
    MonitorInfo(HMONITOR monitorHandle, std::wstring const& displayName)
    {
        MonitorHandle = monitorHandle;
        DisplayName = displayName;
    }

    HMONITOR MonitorHandle;
    std::wstring DisplayName;

    bool operator==(const MonitorInfo& monitor) { return MonitorHandle == monitor.MonitorHandle; }
    bool operator!=(const MonitorInfo& monitor) { return !(*this == monitor); }
};



bool DataClass_One::CheckUserDeviceSupportWGC()
	
{
	if (!GraphicsCaptureSession::IsSupported())
	{
		return false;
	}
	return true;
	
}

// 参数 是否要加一个虚拟显示器用于涵盖多个显示器的画面
std::vector<MonitorInfo> ShaixuanSuoYouXianShiQi(bool includeAllMonitors)
{
    std::vector<MonitorInfo> monitors;
    EnumDisplayMonitors(nullptr, nullptr, [](HMONITOR hmon, HDC, LPRECT, LPARAM lparam)
        {
            auto& monitors = *reinterpret_cast<std::vector<MonitorInfo>*>(lparam);
            monitors.push_back(MonitorInfo(hmon));

            return TRUE;
        }, reinterpret_cast<LPARAM>(&monitors));
    if (monitors.size() > 1 && includeAllMonitors)
    {
        monitors.push_back(MonitorInfo(nullptr, L"All Displays"));
    }
    return monitors;
}

// HMONITOR 转换为 GraphicsCaptureItem 
GraphicsCaptureItem HmoitorTOWinRTGraphicsObj(HMONITOR Inobj)
{
    
    winrt::Windows::Foundation::IActivationFactory WinRTFactory =
        winrt::get_activation_factory<winrt::Windows::Graphics::Capture::GraphicsCaptureItem>();

    
    winrt::com_ptr<IGraphicsCaptureItemInterop> interopFactory =WinRTFactory.as<IGraphicsCaptureItemInterop>();

    winrt::Windows::Graphics::Capture::GraphicsCaptureItem item{ nullptr };

    check_hresult(interopFactory->CreateForMonitor(
        Inobj,
        winrt::guid_of<winrt::Windows::Graphics::Capture::GraphicsCaptureItem>(),
        winrt::put_abi(item)
    ));

    return item;
}



GraphicsCaptureItem DataClass_One::GetMoitorSerial(int xiabiao)
{
     std::vector<MonitorInfo>  xianshiqi_obj = ShaixuanSuoYouXianShiQi(false);
     DataClass_One::Now_Hmoitor_Device = xianshiqi_obj[xiabiao].MonitorHandle;
     return  HmoitorTOWinRTGraphicsObj(DataClass_One::Now_Hmoitor_Device);
}





void DataClass_One::CreateD3DFramePool(
                            IDirect3DDevice  device,
                            GraphicsCaptureItem  WinRTActivateObj,
                            DirectXPixelFormat PixelForamat
)
{
    // 这里缓冲区大小是 单个的 1 * WinRTActivateObj.Size()
    WGC_Frame_Pool= Direct3D11CaptureFramePool::CreateFreeThreaded(device, PixelForamat, 4, WinRTActivateObj.Size());
    WGC_Capture_Session= WGC_Frame_Pool.CreateCaptureSession(WinRTActivateObj);
    WGC_Capture_Session.StartCapture(); // 标志WGC截图开始
    
    WGC_Frame_Pool.FrameArrived([this](auto&& Callobj, auto&& args){
        SetEvent(DataClass_One::FrameArrivedEvent); // 通知有新帧
        DataClass_One::FrameArrived_CallFunction(Callobj);
    });

}


IDirect3DDevice DataClass_One::FromHmonitorFindToIdirect3ddevice()
{
    winrt::com_ptr<IDXGIFactory1> factory;
    CreateDXGIFactory1(__uuidof(IDXGIFactory1), factory.put_void());

    winrt::com_ptr<IDXGIAdapter1> targetAdapter;

    for (UINT adapterIndex = 0;; ++adapterIndex)
    {
        winrt::com_ptr<IDXGIAdapter1> adapter;
        HRESULT adapterResult = factory->EnumAdapters1(adapterIndex, adapter.put());

        if (adapterResult == DXGI_ERROR_NOT_FOUND)
        {
            break;
        }

        for (UINT outputIndex = 0;; ++outputIndex)
        {
            winrt::com_ptr<IDXGIOutput> output;
            HRESULT outputResult = adapter->EnumOutputs(outputIndex, output.put());

            if (outputResult == DXGI_ERROR_NOT_FOUND)
            {
                break;
            }

            DXGI_OUTPUT_DESC outputDescription{};
            output->GetDesc(&outputDescription);

            if (outputDescription.Monitor == Now_Hmoitor_Device)
            {
                targetAdapter = adapter;
                break;
            }
        }

        if (targetAdapter)
        {
            break;
        }
    }

    winrt::com_ptr<ID3D11Device> d3d11Device;
    D3D_FEATURE_LEVEL featureLevel{};

    D3D11CreateDevice(
        targetAdapter.get(),
        D3D_DRIVER_TYPE_UNKNOWN,
        nullptr,
        D3D11_CREATE_DEVICE_BGRA_SUPPORT,
        nullptr,
        0,
        D3D11_SDK_VERSION,
        d3d11Device.put(),
        &featureLevel,
        nullptr
    );

    auto dxgiDevice = d3d11Device.as<IDXGIDevice>();

    winrt::com_ptr<IInspectable> inspectableDevice;
    CreateDirect3D11DeviceFromDXGIDevice(
        dxgiDevice.get(),
        inspectableDevice.put()
    );

    return inspectableDevice.as<IDirect3DDevice>();
} 

void DataClass_One::FrameArrived_CallFunction(winrt::Windows::Graphics::Capture::Direct3D11CaptureFramePool const& sender) {

    // 取帧超时：等帧到达信号，最多 FrameWaitTimeoutMs 毫秒
    DWORD waitResult = WaitForSingleObject(FrameArrivedEvent, 16);
    if (waitResult == WAIT_TIMEOUT)
    {
        return; // 超时，没有等到新帧
    }

    Direct3D11CaptureFrame temp = sender.TryGetNextFrame();
    if (temp==nullptr)
    {
        return;
    }
    // {} 作用是把锁区域限制
    {
        std::unique_lock<std::mutex> lock(FrameLock, std::try_to_lock);
        if (!lock.owns_lock())
        {
            temp = nullptr;
            return;
        }

        GetFrame = temp;
    }
   

}

DataClass_One::DataClass_One()
{
    
}

DataClass_One::~DataClass_One()
{

    try
    {
        if (WGC_Capture_Session)
        {
            WGC_Capture_Session.Close(); // 停止采集
            WGC_Capture_Session = nullptr;
        }

        if (WGC_Frame_Pool)
        {
            WGC_Frame_Pool.Close();      // 关闭帧池，FrameArrived 回调随之停止
            WGC_Frame_Pool = nullptr;
        }
    }
    catch (...)
    {
        
    }

    {
        std::lock_guard<std::mutex> lock(FrameLock);
        GetFrame = nullptr;              // 释放持有的帧，归还给帧池
    }

    if (FrameArrivedEvent != nullptr)
    {
        CloseHandle(FrameArrivedEvent);  // FrameLock 是 std::mutex，没有句柄要关
        FrameArrivedEvent = nullptr;
    }
}