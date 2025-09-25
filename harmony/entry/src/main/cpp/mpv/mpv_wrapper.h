#ifndef MPV_WRAPPER_H
#define MPV_WRAPPER_H

#include <napi/native_api.h>
// #include <mpv/client.h>  // 暂时注释掉，使用模拟实现

#ifdef __cplusplus
extern "C" {
#endif

// 获取MPV API版本
napi_value GetMpvApiVersion(napi_env env, napi_callback_info info);
napi_value MpvCreate(napi_env env, napi_callback_info info);
napi_value LoadVideo(napi_env env, napi_callback_info info);

#ifdef __cplusplus
}
#endif

#endif // MPV_WRAPPER_H