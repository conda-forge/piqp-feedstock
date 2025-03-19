setlocal EnableDelayedExpansion

mkdir conda_build
cd conda_build

cmake %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_WITH_BLASFEO=ON ^
    -DBUILD_TESTS=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

cd ..

REM Build and install static blasfeo libraries used in Python interface
if NOT "%ISA_TARGET%"=="GENERIC" (
    REM download blasfeo
    curl -L https://github.com/giaf/blasfeo/archive/refs/tags/0.1.4.2.tar.gz -o blasfeo.tar.gz
    if errorlevel 1 exit 1
    mkdir blasfeo
    tar -xz --strip-components=1 -C blasfeo/ -f blasfeo.tar.gz
    if errorlevel 1 exit 1
    cd blasfeo

    mkdir build
    cd build

    set "PIQP_CMAKE_ARGS=-DBUILD_WITH_BLASFEO=ON"

    if "%ISA_TARGET%"=="X64" (
        cmake %CMAKE_ARGS% .. ^
            -G "Ninja" ^
            -DCMAKE_C_COMPILER=clang-cl ^
            -DCMAKE_INSTALL_PREFIX=%SRC_DIR%\blasfeo_x64 ^
            -DCMAKE_BUILD_TYPE=Release ^
            -DBLASFEO_CROSSCOMPILING=ON ^
            -DBLAS_API=OFF ^
            -DBLASFEO_EXAMPLES=OFF ^
            -DTARGET=X64_INTEL_CORE
        if errorlevel 1 exit 1
        cmake --build . --config Release
        if errorlevel 1 exit 1
        cmake --build . --config Release --target install
        if errorlevel 1 exit 1
        set "PIQP_CMAKE_ARGS=!PIQP_CMAKE_ARGS! -DBLASFEO_X64_DIR=%SRC_DIR%\blasfeo_x64"

        cmake %CMAKE_ARGS% .. ^
            -G "Ninja" ^
            -DCMAKE_C_COMPILER=clang-cl ^
            -DCMAKE_INSTALL_PREFIX=%SRC_DIR%\blasfeo_x64_avx2 ^
            -DCMAKE_BUILD_TYPE=Release ^
            -DBLASFEO_CROSSCOMPILING=ON ^
            -DBLAS_API=OFF ^
            -DBLASFEO_EXAMPLES=OFF ^
            -DTARGET=X64_INTEL_HASWELL
        if errorlevel 1 exit 1
        cmake --build . --config Release
        if errorlevel 1 exit 1
        cmake --build . --config Release --target install
        if errorlevel 1 exit 1
        set "PIQP_CMAKE_ARGS=!PIQP_CMAKE_ARGS! -DBLASFEO_X64_AVX2_DIR=%SRC_DIR%\blasfeo_x64_avx2"

        cmake %CMAKE_ARGS% .. ^
            -G "Ninja" ^
            -DCMAKE_C_COMPILER=clang-cl ^
            -DCMAKE_INSTALL_PREFIX=%SRC_DIR%\blasfeo_x64_avx512 ^
            -DCMAKE_BUILD_TYPE=Release ^
            -DBLASFEO_CROSSCOMPILING=ON ^
            -DBLAS_API=OFF ^
            -DBLASFEO_EXAMPLES=OFF ^
            -DTARGET=X64_INTEL_SKYLAKE_X
        if errorlevel 1 exit 1
        cmake --build . --config Release
        if errorlevel 1 exit 1
        cmake --build . --config Release --target install
        if errorlevel 1 exit 1
        set "PIQP_CMAKE_ARGS=!PIQP_CMAKE_ARGS! -DBLASFEO_X64_AVX512_DIR=%SRC_DIR%\blasfeo_x64_avx512"
    )

    if "%ISA_TARGET%"=="ARM64" (
        cmake %CMAKE_ARGS% .. ^
            -G "Ninja" ^
            -DCMAKE_C_COMPILER=clang-cl ^
            -DCMAKE_INSTALL_PREFIX=%SRC_DIR%\blasfeo_arm64 ^
            -DCMAKE_BUILD_TYPE=Release ^
            -DBLASFEO_CROSSCOMPILING=ON ^
            -DBLAS_API=OFF ^
            -DBLASFEO_EXAMPLES=OFF ^
            -DTARGET=ARMV8A_APPLE_M1
        if errorlevel 1 exit 1
        cmake --build . --config Release
        if errorlevel 1 exit 1
        cmake --build . --config Release --target install
        if errorlevel 1 exit 1
        set "PIQP_CMAKE_ARGS=!PIQP_CMAKE_ARGS! -DBLASFEO_ARM64_DIR=%SRC_DIR%\blasfeo_arm64"
    )

    if "%ISA_TARGET%"=="AARCH64" (
        cmake %CMAKE_ARGS% .. ^
            -G "Ninja" ^
            -DCMAKE_C_COMPILER=clang-cl ^
            -DCMAKE_INSTALL_PREFIX=%SRC_DIR%\blasfeo_arm64 ^
            -DCMAKE_BUILD_TYPE=Release ^
            -DBLASFEO_CROSSCOMPILING=ON ^
            -DBLAS_API=OFF ^
            -DBLASFEO_EXAMPLES=OFF ^
            -DTARGET=ARMV8A_ARM_CORTEX_A76
        if errorlevel 1 exit 1
        cmake --build . --config Release
        if errorlevel 1 exit 1
        cmake --build . --config Release --target install
        if errorlevel 1 exit 1
        set "PIQP_CMAKE_ARGS=!PIQP_CMAKE_ARGS! -DBLASFEO_ARM64_DIR=%SRC_DIR%\blasfeo_arm64"
    )

    set "CMAKE_ARGS=!CMAKE_ARGS! !PIQP_CMAKE_ARGS!"
    
    cd ..\..
)

%PYTHON% -m pip install . -vv