#ifndef MPV_WRAPPER_H
#define MPV_WRAPPER_H

#include <napi/native_api.h>
#include "ace/xcomponent/native_interface_xcomponent.h"
// #include <mpv/client.h>  // 暂时注释掉，使用模拟实现

#ifdef __cplusplus
extern "C" {
#endif

// New libmpvnative functions for OpenGL rendering
napi_value Create(napi_env env, napi_callback_info info);
napi_value InitSurface(napi_env env, napi_callback_info info);
napi_value SetupGL(napi_env env, napi_callback_info info);
napi_value LoadVideo(napi_env env, napi_callback_info info);
napi_value DestroyGL(napi_env env, napi_callback_info info);
napi_value Destroy(napi_env env, napi_callback_info info);

// XComponent callback functions
void OnSurfaceCreated(OH_NativeXComponent *component, void *window);
void OnSurfaceDestroyed(OH_NativeXComponent *component, void *window);

// Legacy functions (keep for compatibility)
napi_value GetMpvApiVersion(napi_env env, napi_callback_info info);
napi_value MpvCreate(napi_env env, napi_callback_info info);

#ifdef __cplusplus
}
#endif

#endif // MPV_WRAPPER_H