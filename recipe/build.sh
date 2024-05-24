#!/bin/sh

mkdir conda_build
cd conda_build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTS=OFF

cmake --build . --config Release -- -j${CPU_COUNT}

cmake --build . --config Release --target install

cd ..

$PYTHON -m pip install . -vv