#include "mpv_wrapper.h"
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <hilog/log.h>
#include <mpv/client.h>

#define LOG_TAG "MPVWrapper"
#define LOG_DOMAIN 0x3200

// 获取MPV API版本 - 模拟实现
napi_value GetMpvApiVersion(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "GetMpvApiVersion called - Mock implementation");
    
    unsigned long version = mpv_client_api_version();
    napi_value result;
    napi_status status = napi_create_double(env, static_cast<double>(version), &result);
    
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "Failed to create napi_value for MPV API version");
        return nullptr;
    }
    return result;
}

