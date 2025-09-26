# CMakeLists.txt for MPV Native Module
cmake_minimum_required(VERSION 3.16)
project(mpvnative)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

set(MPV_ROOT_PATH ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${MPV_ROOT_PATH}/include)

add_library(player SHARED
    napi_init.cpp
    mpv/mpv_wrapper.cpp
)

find_library(EGL-lib EGL REQUIRED)
find_library(GLES-lib GLESv3 REQUIRED)
find_library(ace-lib ace_ndk.z REQUIRED)
find_library(hilog-lib hilog_ndk.z REQUIRED)
find_library(napi-lib ace_napi.z REQUIRED)
find_library(rawfile-lib rawfile.z REQUIRED)
find_library(uv-lib uv REQUIRED)

target_link_libraries(player PUBLIC
    libace_napi.z.so
    libhilog_ndk.z.so
    libc++.a
    ${EGL-lib}
    ${GLES-lib}
    ${ace-lib}
    ${hilog-lib}
    ${rawfile-lib}
    ${napi-lib}
    ${uv-lib}
    ${MPV_ROOT_PATH}/libmpv.so
    ${MPV_ROOT_PATH}/libavcodec.so
    ${MPV_ROOT_PATH}/libavformat.so
    ${MPV_ROOT_PATH}/libavutil.so
    ${MPV_ROOT_PATH}/libswscale.so
    ${MPV_ROOT_PATH}/libswresample.so
    ${MPV_ROOT_PATH}/libplacebo.so
    ${MPV_ROOT_PATH}/libass.so
)