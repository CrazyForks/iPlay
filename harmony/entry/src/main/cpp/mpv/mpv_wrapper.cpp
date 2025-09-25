#include "mpv_wrapper.h"
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <hilog/log.h>

#define LOG_TAG "MPVWrapper"
#define LOG_DOMAIN 0x3200

// 获取MPV API版本 - 模拟实现
napi_value GetMpvApiVersion(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "GetMpvApiVersion called - Mock implementation");
    
    // 模拟MPV API版本 (2.5 = (2 << 16) | 5 = 131077)
    unsigned long version = 0x20005; // MPV API Version 2.5
    
    napi_value result;
    napi_status status = napi_create_double(env, static_cast<double>(version), &result);
    
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "Failed to create napi_value for MPV API version");
        return nullptr;
    }
    
    OH_LOG_INFO(LOG_APP, "Mock MPV API Version: %lu (Major: %lu, Minor: %lu)", 
                version, (version >> 16), (version & 0xFFFF));
    return result;
}

