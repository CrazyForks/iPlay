# CMakeLists.txt for MPV Native Module
cmake_minimum_required(VERSION 3.16)
project(mpvnative)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

set(MPV_ROOT_PATH ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${MPV_ROOT_PATH}/include)

add_library(mpvnative SHARED
    napi_init.cpp
    mpv/mpv_wrapper.cpp
)

target_link_libraries(mpvnative PUBLIC
    libace_napi.z.so
    libhilog_ndk.z.so
    libc++.a
    ${MPV_ROOT_PATH}/libmpv.so
    ${MPV_ROOT_PATH}/libavcodec.so
    ${MPV_ROOT_PATH}/libavformat.so
    ${MPV_ROOT_PATH}/libavutil.so
    ${MPV_ROOT_PATH}/libswscale.so
    ${MPV_ROOT_PATH}/libswresample.so
    ${MPV_ROOT_PATH}/libplacebo.so
    ${MPV_ROOT_PATH}/libass.so
)