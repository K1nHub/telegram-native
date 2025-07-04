cmake_minimum_required(VERSION 3.9)
project(TELEGRAM_NATIVE)

set(CMAKE_CXX_STANDARD 14)

if (UNIX)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
    set(CMAKE_SHARED_LIBRARY_PREFIX "")
endif ()

find_package(Td 1.8.49 REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(ICU REQUIRED COMPONENTS uc dt)
find_package(ZLIB REQUIRED)

add_library(telegram_native SHARED
        src/stdafx.h
        src/TelegramNative.def
        src/TelegramNative.h
        src/TelegramNative.cpp
        src/dllmain.cpp
        src/exports.cpp)

target_include_directories(telegram_native PRIVATE include)
target_link_libraries(telegram_native PRIVATE
        Td::TdJsonStatic
        ICU::uc ICU::dt)

if (MSVC)
    target_link_libraries(telegram_native PRIVATE
            OpenSSL::SSL OpenSSL::Crypto
            ZLIB::ZLIB)
    set(CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /DNDEBUG")
    set(CMAKE_CXX_FLAGS_DEBUG "/MTd")
    target_compile_definitions(telegram_native PRIVATE _WINDOWS)
endif ()
