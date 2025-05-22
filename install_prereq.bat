@echo off

set _VCPKG_PATH=%~1
set _TARGET_PLATFORM=%~2
set _TARGET_TRIPLET=%_TARGET_PLATFORM%-windows-static

vcpkg install ^
    openssl:%_TARGET_TRIPLET% ^
    zlib:%_TARGET_TRIPLET% ^
    icu:%_TARGET_TRIPLET%
