#include "mpv_wrapper.h"
#include <cstdint>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <hilog/log.h>
#include <string>
#include <thread>
#include <mpv/client.h>
#include <mpv/render.h>
#include <mpv/render_gl.h>

#define LOG_TAG "MPVWrapper"
#define LOG_DOMAIN 0x3200

typedef enum IPLXPlayerPropertyType {
    IPLXPlayerPropertyTypeTimePos = 1,
    IPLXPlayerPropertyTypeDuration,
    IPLXPlayerPropertyTypeVideoParamsAspect,
    IPLXPlayerPropertyTypePausedForCache,
    IPLXPlayerPropertyTypePause,
    IPLXPlayerPropertyTypeEofReached,
    IPLXPlayerPropertyTypeDemuxerCacheState, 
} IPLXPlayerPropertyType;

static void render_update_callback(void *ctx) {
    int size[2] = {1280, 720};
    int channel_size = 4;
    int pitch_size = size[0] * channel_size;
    auto pixels = std::vector<uint8_t>(pitch_size * size[1]);
    mpv_render_param params[] = {
        {MPV_RENDER_PARAM_API_TYPE, (char *)MPV_RENDER_API_TYPE_SW},
        {MPV_RENDER_PARAM_SW_SIZE, size},
        {MPV_RENDER_PARAM_SW_FORMAT, (char *)"rgba"},
        {MPV_RENDER_PARAM_SW_STRIDE, &pitch_size},
        {MPV_RENDER_PARAM_SW_POINTER, (void *)pixels.data()},
        {MPV_RENDER_PARAM_INVALID, nullptr}
    };
    auto *render = (mpv_render_context *)ctx;
    uint64_t flags = mpv_render_context_update(render);
    if (flags & MPV_RENDER_UPDATE_FRAME) {
        mpv_render_context_render(render, params);
        mpv_render_context_report_swap(render);
    }
}

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
    mpv_set_option_string(mpv, "vo", "null");
    mpv_set_option_string(mpv, "ao", "opensles");
    mpv_set_option_string(mpv, "hwdec", "auto");
    mpv_initialize(mpv);
    
    mpv_render_param params[] = {
        {MPV_RENDER_PARAM_API_TYPE, (void *)MPV_RENDER_API_TYPE_SW},
        {MPV_RENDER_PARAM_INVALID}
    };
    
    mpv_render_context *ctx;
    mpv_render_context_create(&ctx, mpv, params);
    mpv_render_context_set_update_callback(ctx, render_update_callback, ctx);
    
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
    
    mpv_observe_property(ctx, IPLXPlayerPropertyTypeTimePos, "time-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(ctx, IPLXPlayerPropertyTypeDuration, "duration", MPV_FORMAT_DOUBLE);
    mpv_observe_property(ctx, IPLXPlayerPropertyTypeVideoParamsAspect, "video-params/aspect", MPV_FORMAT_DOUBLE);
    mpv_observe_property(ctx, IPLXPlayerPropertyTypePausedForCache, "paused-for-cache", MPV_FORMAT_FLAG);
    mpv_observe_property(ctx, IPLXPlayerPropertyTypePause, "pause", MPV_FORMAT_FLAG);
    mpv_observe_property(ctx, IPLXPlayerPropertyTypeEofReached, "eof-reached", MPV_FORMAT_FLAG);
    mpv_observe_property(ctx, IPLXPlayerPropertyTypeDemuxerCacheState, "demuxer-cache-state", MPV_FORMAT_NODE);
    
    auto thread = std::thread([=]() {
        while (ctx) {
            mpv_event *event = mpv_wait_event(ctx, 0);
            mpv_event_id type = event->event_id;
            
            switch (type) {
                case MPV_EVENT_LOG_MESSAGE: {
                    struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
                    OH_LOG_DEBUG(LOG_APP, "mpv [%{public}s] %{public}s: %{public}s", msg->prefix, msg->level, msg->text);
                }
                case MPV_EVENT_PROPERTY_CHANGE: {
                    auto prop = (mpv_event_property *)event->data;
                    auto reply = (IPLXPlayerPropertyType)event->reply_userdata;
                    OH_LOG_DEBUG(LOG_APP, "mpv [%{public}s] %{public}s", "prop", prop->name);
                }
            }
        }
    });
    thread.detach();
    return nullptr;
}