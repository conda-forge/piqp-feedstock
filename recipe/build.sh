#!/bin/sh

mkdir conda_build
cd conda_build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_WITH_BLASFEO=ON \
      -DBUILD_TESTS=OFF

cmake --build . --config Release -- -j${CPU_COUNT}

cmake --build . --config Release --target install

cd ..

# Build and install static blasfeo libraries used in Python interface
if [[ "$ISA_TARGET" != "GENERIC" ]]; then
    # download blasfeo
    curl -L https://github.com/giaf/blasfeo/archive/refs/tags/0.1.4.2.tar.gz -o blasfeo.tar.gz
    mkdir blasfeo
    tar -xz --strip-components=1 -C blasfeo/ -f blasfeo.tar.gz
    cd blasfeo

    mkdir build
    cd build

    export PIQP_CMAKE_ARGS="-DBUILD_WITH_BLASFEO=ON"

    if [[ "$ISA_TARGET" == "X64" ]]; then
        cmake ${CMAKE_ARGS} .. \
              -DCMAKE_INSTALL_PREFIX=$SRC_DIR/blasfeo_x64 \
              -DCMAKE_BUILD_TYPE=Release \
              -DBLASFEO_CROSSCOMPILING=ON \
              -DBLAS_API=OFF \
              -DBLASFEO_EXAMPLES=OFF \
              -DTARGET=X64_INTEL_CORE
        cmake --build . --config Release -- -j${CPU_COUNT}
        cmake --build . --config Release --target install
        export PIQP_CMAKE_ARGS="${PIQP_CMAKE_ARGS} -DBLASFEO_X64_DIR=$SRC_DIR/blasfeo_x64"

        cmake ${CMAKE_ARGS} .. \
              -DCMAKE_INSTALL_PREFIX=$SRC_DIR/blasfeo_x64_avx2 \
              -DCMAKE_BUILD_TYPE=Release \
              -DBLASFEO_CROSSCOMPILING=ON \
              -DBLAS_API=OFF \
              -DBLASFEO_EXAMPLES=OFF \
              -DTARGET=X64_INTEL_HASWELL
        cmake --build . --config Release -- -j${CPU_COUNT}
        cmake --build . --config Release --target install
        export PIQP_CMAKE_ARGS="${PIQP_CMAKE_ARGS} -DBLASFEO_X64_AVX2_DIR=$SRC_DIR/blasfeo_x64_avx2"

        cmake ${CMAKE_ARGS} .. \
              -DCMAKE_INSTALL_PREFIX=$SRC_DIR/blasfeo_x64_avx512 \
              -DCMAKE_BUILD_TYPE=Release \
              -DBLASFEO_CROSSCOMPILING=ON \
              -DBLAS_API=OFF \
              -DBLASFEO_EXAMPLES=OFF \
              -DTARGET=X64_INTEL_SKYLAKE_X
        cmake --build . --config Release -- -j${CPU_COUNT}
        cmake --build . --config Release --target install
        export PIQP_CMAKE_ARGS="${PIQP_CMAKE_ARGS} -DBLASFEO_X64_AVX512_DIR=$SRC_DIR/blasfeo_x64_avx512"
    fi

    if [[ "$ISA_TARGET" == "ARM64" ]]; then
        cmake ${CMAKE_ARGS} .. \
              -DCMAKE_INSTALL_PREFIX=$SRC_DIR/blasfeo_arm64 \
              -DCMAKE_BUILD_TYPE=Release \
              -DBLASFEO_CROSSCOMPILING=ON \
              -DBLAS_API=OFF \
              -DBLASFEO_EXAMPLES=OFF \
              -DTARGET=ARMV8A_APPLE_M1
        cmake --build . --config Release -- -j${CPU_COUNT}
        cmake --build . --config Release --target install
        export PIQP_CMAKE_ARGS="${PIQP_CMAKE_ARGS} -DBLASFEO_ARM64_DIR=$SRC_DIR/blasfeo_arm64"
    fi

    if [[ "$ISA_TARGET" == "AARCH64" ]]; then
        cmake ${CMAKE_ARGS} .. \
              -DCMAKE_INSTALL_PREFIX=$SRC_DIR/blasfeo_arm64 \
              -DCMAKE_BUILD_TYPE=Release \
              -DBLASFEO_CROSSCOMPILING=ON \
              -DBLAS_API=OFF \
              -DBLASFEO_EXAMPLES=OFF \
              -DTARGET=ARMV8A_ARM_CORTEX_A76
        cmake --build . --config Release -- -j${CPU_COUNT}
        cmake --build . --config Release --target install
        export PIQP_CMAKE_ARGS="${PIQP_CMAKE_ARGS} -DBLASFEO_ARM64_DIR=$SRC_DIR/blasfeo_arm64"
    fi

    export CMAKE_ARGS="${CMAKE_ARGS} ${PIQP_CMAKE_ARGS}"

    cd ../..
fi

$PYTHON -m pip install . -vv