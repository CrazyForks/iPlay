# CMakeLists.txt for MPV Native Module

cmake_minimum_required(VERSION 3.16)
project(mpvnative)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# 设置MPV库路径
set(MPV_ROOT_PATH ${NATIVERENDER_ROOT_PATH}/../../../../library/mpv)

# 包含头文件路径 - 必须在add_library之前
include_directories(${NATIVERENDER_ROOT_PATH}
                    ${MPV_ROOT_PATH}/include)

# 链接库路径
link_directories(${MPV_ROOT_PATH}/lib)

# 添加源文件
add_library(mpvnative SHARED
    napi_init.cpp
    mpv/mpv_wrapper.cpp
)

# 链接必要的库
target_link_libraries(mpvnative PUBLIC 
    libace_napi.z.so 
    libhilog_ndk.z.so 
    libc++.a
    libmpv.so
    libavcodec.so
    libavformat.so
    libavutil.so
    libswscale.so
    libswresample.so
    libplacebo.so
    libass.so
)