#include "mpv_wrapper.h"
#include <cstdint>
#include <string>
#include <thread>
#include <vector>

// HarmonyOS NAPI and XComponent
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <hilog/log.h>
#include "ace/xcomponent/native_interface_xcomponent.h"

// MPV headers
#include <mpv/client.h>
#include <mpv/render.h>
#include <mpv/render_gl.h>

// OpenGL ES headers
#include <EGL/egl.h>
#include <GLES3/gl3.h>


// Global state for OpenGL and MPV
static EGLDisplay eglDisplay = EGL_NO_DISPLAY;
static EGLContext eglContext = EGL_NO_CONTEXT;
static EGLSurface eglSurface = EGL_NO_SURFACE;
static mpv_render_context *mpvRenderCtx = nullptr;
static mpv_handle *global_mpv = nullptr;
static OH_NativeXComponent *nativeXComponent = nullptr;
static int surfaceWidth = 1280;
static int surfaceHeight = 720;

typedef enum IPLXPlayerPropertyType {
    IPLXPlayerPropertyTypeTimePos = 1,
    IPLXPlayerPropertyTypeDuration,
    IPLXPlayerPropertyTypeVideoParamsAspect,
    IPLXPlayerPropertyTypePausedForCache,
    IPLXPlayerPropertyTypePause,
    IPLXPlayerPropertyTypeEofReached,
    IPLXPlayerPropertyTypeDemuxerCacheState, 
} IPLXPlayerPropertyType;

// OpenGL function loader for mpv
static void* get_proc_address(void *ctx, const char *name) {
    void* proc = (void*)eglGetProcAddress(name);
    if (!proc) {
        OH_LOG_ERROR(LOG_APP, "Failed to get proc address for: %s", name);
    }
    return proc;
}

// Legacy software render callback - for backward compatibility
static void render_update_callback(void *ctx) {
    // Legacy software rendering implementation
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

// Simple render function without callback complications
static void simple_render() {
    if (eglSurface == EGL_NO_SURFACE || mpvRenderCtx == nullptr) {
        OH_LOG_ERROR(LOG_APP, "simple_render: Invalid state");
        return;
    }
    
    // Ensure EGL context is current
    if (eglGetCurrentContext() != eglContext) {
        if (!eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)) {
            OH_LOG_ERROR(LOG_APP, "simple_render: Failed to make EGL context current");
            return;
        }
    }
    
    uint64_t flags = mpv_render_context_update(mpvRenderCtx);
    if (flags & MPV_RENDER_UPDATE_FRAME) {
        mpv_opengl_fbo fbo = {.fbo = 0, .w = surfaceWidth, .h = surfaceHeight};
        mpv_render_param params[] = {
            {MPV_RENDER_PARAM_OPENGL_FBO, &fbo},
            {MPV_RENDER_PARAM_INVALID, nullptr}
        };
        
        // Simple render without extensive logging
        mpv_render_context_render(mpvRenderCtx, params);
        eglSwapBuffers(eglDisplay, eglSurface);
        mpv_render_context_report_swap(mpvRenderCtx);
    }
}

// OpenGL render callback - called by mpv when a new frame is ready
static void on_mpv_render(void *ctx) {
    OH_LOG_INFO(LOG_APP, "on_mpv_render called - delegating to simple_render");
    simple_render();
}

// XComponent lifecycle callbacks
void OnSurfaceCreated(OH_NativeXComponent *component, void *window) {
    OH_LOG_INFO(LOG_APP, "OnSurfaceCreated called");
    nativeXComponent = component;
    
    // Initialize EGL with the provided window
    eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    eglInitialize(eglDisplay, nullptr, nullptr);

    EGLint attribs[] = {
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT,
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_RED_SIZE, 8, EGL_GREEN_SIZE, 8, EGL_BLUE_SIZE, 8, EGL_ALPHA_SIZE, 8,
        EGL_DEPTH_SIZE, 16,
        EGL_NONE
    };
    EGLConfig config;
    EGLint numConfigs;
    eglChooseConfig(eglDisplay, attribs, &config, 1, &numConfigs);

    EGLint ctx_attribs[] = {EGL_CONTEXT_CLIENT_VERSION, 3, EGL_NONE};
    eglContext = eglCreateContext(eglDisplay, config, EGL_NO_CONTEXT, ctx_attribs);
    eglSurface = eglCreateWindowSurface(eglDisplay, config, (EGLNativeWindowType)window, nullptr);
    
    eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext);
    
    // Get surface dimensions
    eglQuerySurface(eglDisplay, eglSurface, EGL_WIDTH, &surfaceWidth);
    eglQuerySurface(eglDisplay, eglSurface, EGL_HEIGHT, &surfaceHeight);
    
    OH_LOG_INFO(LOG_APP, "EGL initialized, surface size: %dx%d", surfaceWidth, surfaceHeight);
}

void OnSurfaceDestroyed(OH_NativeXComponent *component, void *window) {
    OH_LOG_INFO(LOG_APP, "OnSurfaceDestroyed called");
    
    // Cleanup EGL resources
    if (eglDisplay != EGL_NO_DISPLAY) {
        eglMakeCurrent(eglDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (eglSurface != EGL_NO_SURFACE) {
            eglDestroySurface(eglDisplay, eglSurface);
            eglSurface = EGL_NO_SURFACE;
        }
        if (eglContext != EGL_NO_CONTEXT) {
            eglDestroyContext(eglDisplay, eglContext);
            eglContext = EGL_NO_CONTEXT;
        }
        eglTerminate(eglDisplay);
        eglDisplay = EGL_NO_DISPLAY;
    }
}

// NAPI functions for ArkTS integration

napi_value Create(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "libmpvnative: Create called");
    
    if (global_mpv) {
        mpv_terminate_destroy(global_mpv);
        global_mpv = nullptr;
    }

    global_mpv = mpv_create();
    if (!global_mpv) {
        OH_LOG_ERROR(LOG_APP, "Failed to create mpv handle");
        return nullptr;
    }
    
    // Configure mpv for OpenGL rendering
    mpv_request_log_messages(global_mpv, "debug");
    mpv_set_option_string(global_mpv, "vo", "libmpv");
    mpv_set_option_string(global_mpv, "ao", "opensles");
    mpv_set_option_string(global_mpv, "hwdec", "auto-copy");
    
    if (mpv_initialize(global_mpv) < 0) {
        OH_LOG_ERROR(LOG_APP, "Failed to initialize mpv");
        mpv_terminate_destroy(global_mpv);
        global_mpv = nullptr;
        return nullptr;
    }
    
    OH_LOG_INFO(LOG_APP, "mpv instance created successfully");
    napi_value result;
    napi_create_int64(env, (int64_t)global_mpv, &result);
    return result;
}



napi_value InitSurface(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "libmpvnative: InitSurface called");
    
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    if (argc < 1) {
        OH_LOG_ERROR(LOG_APP, "InitSurface: Expected surface ID parameter");
        return nullptr;
    }
    
    char surfaceId[128];
    size_t result_len;
    napi_get_value_string_utf8(env, args[0], surfaceId, sizeof(surfaceId), &result_len);
    
    OH_LOG_INFO(LOG_APP, "InitSurface: Surface ID = %s", surfaceId);
    
    return nullptr;
}

napi_value SetupGL(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "libmpvnative: SetupGL called");
    
    if (!global_mpv) {
        OH_LOG_ERROR(LOG_APP, "SetupGL: mpv not initialized");
        return nullptr;
    }
    
    if (eglDisplay == EGL_NO_DISPLAY) {
        OH_LOG_ERROR(LOG_APP, "SetupGL: EGL not initialized");
        return nullptr;
    }
    
    // Ensure EGL context is current before creating render context
    if (!eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)) {
        OH_LOG_ERROR(LOG_APP, "SetupGL: Failed to make EGL context current");
        return nullptr;
    }
    
    // Check OpenGL state
    GLenum glError = glGetError();
    if (glError != GL_NO_ERROR) {
        OH_LOG_ERROR(LOG_APP, "SetupGL: OpenGL error before setup: 0x%x", glError);
    }
    
    OH_LOG_INFO(LOG_APP, "Current EGL context: %p, surface: %p", eglGetCurrentContext(), eglGetCurrentSurface(EGL_DRAW));
    
    // Set up OpenGL viewport
    glViewport(0, 0, surfaceWidth, surfaceHeight);
    OH_LOG_INFO(LOG_APP, "Set OpenGL viewport to %dx%d", surfaceWidth, surfaceHeight);
    
    // Clear any existing OpenGL errors
    while (glGetError() != GL_NO_ERROR) {
        // Clear error queue
    }
    
    // Initialize mpv OpenGL renderer
    mpv_opengl_init_params gl_init_params = {
        .get_proc_address = get_proc_address
    };
    
    mpv_render_param params[] = {
        {MPV_RENDER_PARAM_API_TYPE, (void*)MPV_RENDER_API_TYPE_OPENGL},
        {MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &gl_init_params},
        {MPV_RENDER_PARAM_INVALID, nullptr}
    };

    OH_LOG_INFO(LOG_APP, "Creating mpv render context...");
    int create_result = mpv_render_context_create(&mpvRenderCtx, global_mpv, params);
    if (create_result < 0) {
        OH_LOG_ERROR(LOG_APP, "Failed to create mpv render context, error: %d", create_result);
        return nullptr;
    }
    OH_LOG_INFO(LOG_APP, "mpv render context created successfully");

    // Set the render callback - try different approach
    OH_LOG_INFO(LOG_APP, "Setting mpv render update callback");
    
    // First, try a simple test render to see if basic rendering works
    OH_LOG_INFO(LOG_APP, "Testing basic mpv render...");
    mpv_opengl_fbo test_fbo = {
        .fbo = 0,
        .w = surfaceWidth,
        .h = surfaceHeight,
    };
    mpv_render_param test_params[] = {
        {MPV_RENDER_PARAM_OPENGL_FBO, &test_fbo},
        {MPV_RENDER_PARAM_INVALID, nullptr}
    };
    
    // Try a test render - this should be quick if no video is loaded
    OH_LOG_INFO(LOG_APP, "Calling test render...");
    int test_result = mpv_render_context_render(mpvRenderCtx, test_params);
    OH_LOG_INFO(LOG_APP, "Test render result: %d", test_result);
    
    // Now set the callback
    mpv_render_context_set_update_callback(mpvRenderCtx, on_mpv_render, nullptr);
    OH_LOG_INFO(LOG_APP, "OpenGL setup completed successfully");
    
    return nullptr;
}

napi_value LoadVideo(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "libmpvnative: LoadVideo called");
    
    size_t argc = 2;
    napi_value args[2];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    if (argc < 2) {
        OH_LOG_ERROR(LOG_APP, "LoadVideo: Expected mpv handle and URL");
        return nullptr;
    }
    
    int64_t mpv_ptr;
    napi_get_value_int64(env, args[0], &mpv_ptr);
    
    char url[1024];
    size_t url_len;
    napi_get_value_string_utf8(env, args[1], url, sizeof(url), &url_len);
    
    auto ctx = (mpv_handle *)mpv_ptr;
//    if (ctx != global_mpv) {
//        OH_LOG_ERROR(LOG_APP, "LoadVideo: Invalid mpv handle");
//        return nullptr;
//    }

    OH_LOG_INFO(LOG_APP, "Loading video: %s", url);
    const char *cmd[] = {"loadfile", url, "replace", NULL};
    int cmd_result = mpv_command(ctx, cmd);
    OH_LOG_INFO(LOG_APP, "mpv_command loadfile result: %d", cmd_result);
    
    // Also try to trigger a manual render update
    if (mpvRenderCtx) {
        OH_LOG_INFO(LOG_APP, "Triggering manual render update after loading video");
        on_mpv_render(nullptr);
    }
    
    // Start event loop in a separate thread
    auto thread = std::thread([=]() {
        while (global_mpv) {
            mpv_event *event = mpv_wait_event(global_mpv, 1.0);
            if (event->event_id == MPV_EVENT_NONE) continue;
            if (event->event_id == MPV_EVENT_SHUTDOWN) {
                OH_LOG_INFO(LOG_APP, "MPV shutdown event received");
                break;
            }
        }
    });
    thread.detach();
    
    return nullptr;
}

napi_value DestroyGL(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "libmpvnative: DestroyGL called");
    
    if (mpvRenderCtx) {
        mpv_render_context_free(mpvRenderCtx);
        mpvRenderCtx = nullptr;
    }
    
    // EGL cleanup is handled in OnSurfaceDestroyed
    return nullptr;
}

napi_value Destroy(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "libmpvnative: Destroy called");
    
    if (global_mpv) {
        mpv_terminate_destroy(global_mpv);
        global_mpv = nullptr;
    }
    
    return nullptr;
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
    
    // Legacy software rendering - deprecated
    // Use the new OpenGL-based rendering instead
    
    napi_value result;
    napi_create_int64(env, (int64_t)mpv, &result);
    return result;
}
