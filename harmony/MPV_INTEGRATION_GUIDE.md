# HarmonyOS MPV集成指南

本文档详细说明如何在HarmonyOS ArkTS项目中集成MPV库并调用`mpv_client_api_version`函数。

## 🎯 目标

在HarmonyOS应用中调用MPV C库的`mpv_client_api_version()`函数来获取API版本信息。

## 📁 项目结构

```
entry/
├── src/main/
│   ├── cpp/                     # C++ Native代码 (需要创建)
│   │   ├── CMakeLists.txt       # CMake配置
│   │   ├── napi_init.cpp        # NAPI模块入口
│   │   └── mpv/
│   │       ├── mpv_wrapper.h    # MPV包装器头文件
│   │       └── mpv_wrapper.cpp  # MPV包装器实现
│   ├── ets/
│   │   ├── mpv/                 # ArkTS MPV接口
│   │   │   ├── MpvPlayer.ets    # MPV播放器类
│   │   │   ├── MpvTypes.ets     # 类型定义
│   │   │   └── index.ets        # 导出文件
│   │   └── pages/
│   │       └── PlayerPageMpv.ets # 使用示例页面
│   └── module.json5             # 模块配置
├── build-profile.json5          # 构建配置
└── library/                     # MPV库文件
    └── mpv/
        ├── include/
        │   └── mpv/
        │       └── client.h     # MPV头文件
        └── lib/
            └── libmpv.so        # MPV库文件
```

## 🔧 实现步骤

### 1. C++ Native层实现

#### mpv_wrapper.h
```cpp
#ifndef MPV_WRAPPER_H
#define MPV_WRAPPER_H

#include <napi/native_api.h>
#include <mpv/client.h>

#ifdef __cplusplus
extern "C" {
#endif

// 获取MPV API版本 - 调用 mpv_client_api_version()
napi_value GetMpvApiVersion(napi_env env, napi_callback_info info);

#ifdef __cplusplus
}
#endif

#endif
```

#### mpv_wrapper.cpp
```cpp
#include "mpv_wrapper.h"
#include <hilog/log.h>

#define LOG_TAG "MPVWrapper"

// 获取MPV API版本
napi_value GetMpvApiVersion(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "Calling mpv_client_api_version()");
    
    // 关键调用：这里直接调用MPV C API函数
    unsigned long version = mpv_client_api_version();
    
    // 解析版本信息
    unsigned int major = (version >> 16) & 0xFFFF;
    unsigned int minor = version & 0xFFFF;
    
    OH_LOG_INFO(LOG_APP, "MPV API Version: %lu (Major: %u, Minor: %u)", 
                version, major, minor);
    
    // 转换为NAPI值返回
    napi_value result;
    napi_status status = napi_create_double(env, static_cast<double>(version), &result);
    
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "Failed to create napi_value");
        return nullptr;
    }
    
    return result;
}
```

#### CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.16)
project(mpvnative)

# 设置路径
set(MPV_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../../library/mpv)

# 创建共享库
add_library(mpvnative SHARED
    napi_init.cpp
    mpv/mpv_wrapper.cpp
)

# 设置头文件路径
target_include_directories(mpvnative PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${MPV_ROOT_PATH}/include
)

# 链接库
target_link_libraries(mpvnative 
    libace_napi.z.so 
    libhilog_ndk.z.so
    ${MPV_ROOT_PATH}/lib/libmpv.so
)
```

### 2. 构建配置

#### build-profile.json5
```json
{
  "apiType": "stageMode",
  "buildOption": {
    "externalNativeOptions": {
      "path": "./src/main/cpp/CMakeLists.txt",
      "arguments": "",
      "cppFlags": "-I../../library/mpv/include"
    }
  }
}
```

### 3. ArkTS层接口

#### MpvPlayer.ets
```typescript
export class MpvPlayer {
  private mpvNative: any;
  
  constructor() {
    // 加载native模块
    this.mpvNative = globalThis.requireNapi('mpvnative');
  }
  
  /**
   * 获取MPV API版本
   * 这个函数最终会调用C层的mpv_client_api_version()
   */
  async getApiVersion(): Promise<number> {
    try {
      return await this.mpvNative.getMpvApiVersion();
    } catch (error) {
      console.error('Failed to get MPV API version:', error);
      throw error;
    }
  }
}
```

### 4. 使用示例

```typescript
import { MpvPlayer } from '../mpv/MpvPlayer';

// 创建播放器实例
const player = new MpvPlayer();

// 调用mpv_client_api_version函数
const apiVersion = await player.getApiVersion();
console.log(`MPV API Version: ${apiVersion}`);

// 解析版本号
const major = (apiVersion >> 16) & 0xFFFF;
const minor = apiVersion & 0xFFFF;
console.log(`Version: ${major}.${minor}`);
```

## 🚨 关键注意事项

### 1. 库文件要求
- MPV库必须为HarmonyOS架构编译 (aarch64-linux-ohos)
- 包含所有依赖库 (ffmpeg, libass等)
- 确保ABI兼容性

### 2. 头文件路径
- 使用 `#include <mpv/client.h>` 而不是相对路径
- 在CMakeLists.txt中正确设置include路径
- 确保编译器能找到所有头文件

### 3. 链接配置
```cmake
# 正确的链接方式
target_link_libraries(mpvnative 
    libace_napi.z.so 
    libhilog_ndk.z.so
    ${MPV_ROOT_PATH}/lib/libmpv.so
)
```

### 4. 权限配置
在module.json5中添加必要权限：
```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      }
    ]
  }
}
```

## 🔍 调试技巧

### 1. 验证MPV库
```bash
# 检查库文件架构
file library/mpv/lib/libmpv.so

# 检查符号
nm -D library/mpv/lib/libmpv.so | grep mpv_client_api_version
```

### 2. 编译调试
```bash
# 详细编译信息
hvigorw assembleHap --info

# 清理重编译
hvigorw clean
hvigorw assembleHap
```

### 3. 运行时调试
```typescript
// 在ArkTS中添加日志
console.info(`MPV API Version: 0x${apiVersion.toString(16)}`);
```

## 📋 故障排除

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 头文件找不到 | 路径配置错误 | 检查CMakeLists.txt中的include_directories |
| 库文件链接失败 | 库不存在或架构不匹配 | 确认MPV库为HarmonyOS编译 |
| 运行时崩溃 | ABI不兼容 | 重新编译MPV库 |
| NAPI调用失败 | 模块注册问题 | 检查napi_init.cpp |

## ✅ 验证成功

如果集成成功，应该能看到：
```
MPV API Version: 131077 (0x20005)
Major Version: 2
Minor Version: 5
```

这表明成功调用了`mpv_client_api_version()`函数并获取到了正确的API版本信息。