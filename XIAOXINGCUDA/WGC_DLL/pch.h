#pragma once
#include <iostream>
#include <string.h>

#include <Windows.h>
#include <mutex>

#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.graphics.Capture.h>
#include <winrt/Windows.graphics.DirectX.h>
#include <winrt/Windows.graphics.DirectX.Direct3D11.h>

#include <windows.graphics.capture.interop.h>
#include <windows.graphics.directx.direct3d11.interop.h>

// 放在头文件里才能传递给所有包含它的工程（XIAOXINGCUDA.cpp -> Data_One.h -> 这里）
#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "dxgi.lib")
#pragma comment(lib, "windowsapp.lib")
