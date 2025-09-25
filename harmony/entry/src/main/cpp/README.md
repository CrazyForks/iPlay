# MPV Player Integration for HarmonyOS

这个项目演示了如何在HarmonyOS ArkTS应用中集成MPV媒体播放器库。

## 项目结构

```
entry/src/main/
├── cpp/                          # C++ Native代码
│   ├── CMakeLists.txt           # CMake配置文件
│   ├── napi_init.cpp            # NAPI模块注册
│   └── mpv/
│       ├── mpv_wrapper.h        # MPV包装器头文件
│       └── mpv_wrapper.cpp      # MPV包装器实现
├── ets/
│   ├── mpv/                     # ArkTS MPV包装器
│   │   ├── MpvTypes.ets         # 类型定义
│   │   ├── MpvPlayer.ets        # MPV播放器类
│   │   ├── MpvTestPage.ets      # 测试页面
│   │   ├── MpvApiTest.ets       # API测试类
│   │   └── index.ets            # 导出文件
│   └── pages/
│       └── PlayerPageMpv.ets    # 集成了MPV的播放页面
└── module.json5                 # 模块配置（包含native库声明）
```

## 主要功能

### 1. MPV API版本获取
通过调用 `mpv_client_api_version()` 函数获取MPV库的API版本：

```typescript
const mpvPlayer = new MpvPlayer();
const apiVersion = await mpvPlayer.getApiVersion();
console.log(`MPV API Version: ${apiVersion}`);
```

### 2. MPV实例管理
- 创建和销毁MPV播放器实例
- 配置播放器参数
- 管理播放器状态

### 3. 媒体播放控制
- 加载视频文件/URL
- 播放/暂停/停止
- 跳转进度
- 音量控制

### 4. 属性获取和设置
- 获取播放时间、总时长等信息
- 设置播放器属性

## 关键实现

### C++ Native层
1. **MPV包装器** (`mpv_wrapper.cpp`):
   - 封装MPV C API为NAPI函数
   - 提供实例管理和命令接口
   - 处理错误和日志

2. **NAPI模块** (`napi_init.cpp`):
   - 注册native函数到ArkTS
   - 导出为 `mpvnative` 模块

### ArkTS层
1. **MpvPlayer类** (`MpvPlayer.ets`):
   - 高级MPV播放器接口
   - 异步操作包装
   - 状态管理

2. **类型定义** (`MpvTypes.ets`):
   - TypeScript接口定义
   - 枚举和配置类型

## 编译配置

### 1. CMakeLists.txt
```cmake
# 包含MPV头文件
include_directories(${NATIVERENDER_ROOT_PATH}/../../../../library/mpv/include)

# 链接MPV库
target_link_libraries(mpvnative PUBLIC libmpv.so ...)
```

### 2. build-profile.json5
```json
{
  "buildOption": {
    "externalNativeOptions": {
      "path": "./src/main/cpp/CMakeLists.txt"
    }
  }
}
```

### 3. module.json5
```json
{
  "module": {
    "nativeLibrary": ["libmpvnative.so"]
  }
}
```

## 使用示例

### 基本播放
```typescript
import { MpvPlayer, MpvConfig } from '../mpv/index';

const player = new MpvPlayer();

// 初始化
const config: MpvConfig = {
  vo: 'gpu',
  ao: 'audiotrack',
  hwdec: true
};
await player.initialize(config);

// 播放视频
await player.loadFile('https://example.com/video.mp4');
await player.play();
```

### API版本测试
```typescript
import { MpvApiTest } from '../mpv/index';

const test = new MpvApiTest();
await test.runAllTests(); // 运行所有MPV API测试
```

## 库路径标准化

原始MPV库位于 `library/mpv/lib/` 路径，为了符合ArkTS标准：

1. **保持原有结构**: MPV库文件保持在原始位置
2. **CMake配置**: 通过相对路径引用库文件
3. **Native模块**: 创建标准的 `src/main/cpp` 结构
4. **模块声明**: 在 `module.json5` 中正确声明native库

## 注意事项

1. **权限**: 确保应用有网络访问权限
2. **架构**: MPV库需要与目标设备架构匹配
3. **依赖**: 确保所有MPV依赖库都已包含
4. **错误处理**: 实现合适的错误处理和降级机制

## 测试

运行MPV测试页面可以验证：
- MPV API版本获取 (调用 `mpv_client_api_version`)
- 实例创建和销毁
- 基本播放功能

## 故障排除

1. **编译错误**: 检查CMake路径和库链接
2. **运行时错误**: 检查native库是否正确打包
3. **API调用失败**: 检查MPV库是否与设备兼容