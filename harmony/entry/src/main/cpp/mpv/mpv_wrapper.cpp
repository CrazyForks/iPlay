#include "mpv_wrapper.h"
#include <cstdint>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <hilog/log.h>
#include <mpv/client.h>
#include <string>
#include <thread>

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

napi_value MpvCreate(napi_env env, napi_callback_info info) {
    auto mpv = mpv_create();
    mpv_request_log_messages(mpv, "debug");
    mpv_set_option_string(mpv, "vo", "libmpv");
    mpv_set_option_string(mpv, "hwdec", "auto");
    mpv_initialize(mpv);
    napi_value result;
    napi_create_int64(env, (int64_t)mpv, &result);
    return result;
}

napi_value LoadVideo(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "%s", __func__);
    
    // 获取参数
    size_t argc = 2;
    napi_value args[2];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    if (argc < 2) {
        napi_throw_error(env, nullptr, "Expected 2 arguments");
        return nullptr;
    }
    
    // 解析参数
    int64_t mpv;
    napi_get_value_int64(env, args[0], &mpv);
    
    char url[1024];
    size_t url_len;
    napi_get_value_string_utf8(env, args[1], url, sizeof(url), &url_len);
    url[url_len] = '\0';
    std::string source = std::string(url);

    auto ctx = (mpv_handle *)mpv;
    OH_LOG_INFO(LOG_APP, "LoadVideo: mpv=%{public}p, url=%{public}s", ctx, source.data());
    const char *cmd[] = {
        "loadfile", source.data(), "replace", NULL
    };
    mpv_command(ctx, cmd);
    
    auto thread = std::thread([&]() {
        while (ctx) {
            mpv_event *event = mpv_wait_event(ctx, 0);
            mpv_event_id type = event->event_id;
            
            switch (type) {
                case MPV_EVENT_LOG_MESSAGE: {
                    struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
                    OH_LOG_DEBUG(LOG_APP, "mpv [%{public}s] %{public}s: %{public}s", msg->prefix, msg->level, msg->text);
                }
            }
        }
    });
    thread.detach();
    return nullptr;
}