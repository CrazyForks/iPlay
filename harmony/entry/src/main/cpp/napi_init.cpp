#include <napi/native_api.h>
#include "mpv/mpv_wrapper.h"

static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"GetMpvApiVersion", nullptr, GetMpvApiVersion, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"LoadVideo", nullptr, LoadVideo, nullptr, nullptr, nullptr, napi_default, nullptr },
        {"MpvCreate", nullptr, MpvCreate, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "mpvnative",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterMpvNativeModule(void) {
    napi_module_register(&demoModule);
}