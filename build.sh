set -euo pipefail

if [ -z "$1" ]; then
    BUILD_NAME="dev"
else
    BUILD_NAME=$1
fi
if [ "${BUILD_NAME}" = "dev" ]; then
    CMAKE_ROOT="../dandelion"
    ARTIFACTS_DEBUG="dandelion"
    ARTIFACTS_RELEASE="dandelion"
elif [ "${BUILD_NAME}" = "dev-lib" ]; then
    CMAKE_ROOT="../dandelion/lib"
    ARTIFACTS_DEBUG="libdandelion-bvh-debug.a libdandelion-ray-debug.a"
    ARTIFACTS_RELEASE="libdandelion-bvh.a libdandelion-ray.a"
elif [ "${BUILD_NAME}" = "release" ]; then
    CMAKE_ROOT="../dandelion"
    ARTIFACTS_DEBUG="dandelion"
    ARTIFACTS_RELEASE="dandelion"
fi

DEBUG_LOG="/root/build_output/${OS_NAME}-debug.log"
RELEASE_LOG="/root/build_output/${OS_NAME}-release.log"
DEBUG_ARTIFACTS_DIR="/root/build_output/${OS_NAME}-debug-artifacts"
RELEASE_ARTIFACTS_DIR="/root/build_output/${OS_NAME}-release-artifacts"
touch ${DEBUG_LOG}
touch ${RELEASE_LOG}
chmod 666 ${DEBUG_LOG}
chmod 666 ${RELEASE_LOG}
mkdir -p ${DEBUG_ARTIFACTS_DIR}
mkdir -p ${RELEASE_ARTIFACTS_DIR}

mkdir build
cd build

echo "configure dandelion(${BUILD_NAME}) (debug)"
cmake -S ${CMAKE_ROOT} -B . -DCMAKE_BUILD_TYPE=Debug 2>&1 | tee ${DEBUG_LOG}
echo 'done'
echo "building dandelion(${BUILD_NAME}) (debug)"
cmake --build . --parallel $(nproc) 2>&1 | tee -a ${DEBUG_LOG}
echo 'done'

for artifact in ${ARTIFACTS_DEBUG}; do
    cp "./$artifact" ${DEBUG_ARTIFACTS_DIR}/
done

echo "configure dandelion(${BUILD_NAME}) (release)"
cmake -S ${CMAKE_ROOT} -B . -DCMAKE_BUILD_TYPE=Release 2>&1 | tee ${RELEASE_LOG}
echo 'done'
echo "building dandelion(${BUILD_NAME}) (release)"
cmake --build . --parallel $(nproc) 2>&1 | tee -a ${RELEASE_LOG}
echo 'done'

for artifact in ${ARTIFACTS_RELEASE}; do
    cp "./$artifact" ${RELEASE_ARTIFACTS_DIR}/
done
