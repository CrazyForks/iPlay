#include <napi/native_api.h>
#include "ace/xcomponent/native_interface_xcomponent.h"
#include "mpv/mpv_wrapper.h"

namespace {
    // Main entry point - called on any 'import' instruction or 'XComponent' with 'libraryname' "libmpvnative"
    [[nodiscard]] napi_value Invoke(napi_env env, napi_value exports) {
        // Check if this is an XComponent request
        napi_value xComponentJS;
        napi_status const check = napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &xComponentJS);
        
        if (check == napi_ok) {
            OH_NativeXComponent *xComponent;
            if (napi_unwrap(env, xComponentJS, reinterpret_cast<void **>(&xComponent)) == napi_ok) {
                // This is a UI/XComponent request - register callbacks
                static OH_NativeXComponent_Callback callbacks{
                    .OnSurfaceCreated = OnSurfaceCreated,
                    .OnSurfaceChanged = nullptr,
                    .OnSurfaceDestroyed = OnSurfaceDestroyed,
                    .DispatchTouchEvent = nullptr
                };
                
                OH_NativeXComponent_RegisterCallback(xComponent, &callbacks);
                return exports; // Return exports to indicate success
            }
        }
        
        // This is a regular ArkTS script request - register NAPI functions
        napi_property_descriptor desc[] = {
            {"create", nullptr, Create, nullptr, nullptr, nullptr, napi_default, nullptr},
            {"initSurface", nullptr, InitSurface, nullptr, nullptr, nullptr, napi_default, nullptr},
            {"setupGL", nullptr, SetupGL, nullptr, nullptr, nullptr, napi_default, nullptr},
            {"loadVideo", nullptr, LoadVideo, nullptr, nullptr, nullptr, napi_default, nullptr},
            {"destroyGL", nullptr, DestroyGL, nullptr, nullptr, nullptr, napi_default, nullptr},
            {"destroy", nullptr, Destroy, nullptr, nullptr, nullptr, napi_default, nullptr},
        };
        
        napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
        return exports;
    }

    __attribute__((constructor)) void RegisterMpvNativeModule() noexcept {
        napi_module appModule{
            .nm_version = 1,
            .nm_flags = 0U,
            .nm_filename = nullptr,
            .nm_register_func = &Invoke,
            .nm_modname = "player",
            .nm_priv = nullptr,
            .reserved = {}
        };

        napi_module_register(&appModule);
    }
}

