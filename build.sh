set -euo pipefail

# Use assumed dandelion path in docker container
DANDELION_PATH=${DANDELION_PATH:-"dandelion"}
BUILD_PATH=${BUILD_PATH:-"build"}
BUILD_OUTPUT_PATH=${BUILD_OUTPUT_PATH:-"build_output"}

BUILD_KIND=${1:-"dev"}
if [ "${BUILD_KIND}" = "dev" ]; then
    CMAKE_ROOT="${DANDELION_PATH}"
    ARTIFACTS_DEBUG="dandelion"
    ARTIFACTS_RELEASE="dandelion"
elif [ "${BUILD_KIND}" = "lib" ]; then
    CMAKE_ROOT="${DANDELION_PATH}/lib"
    ARTIFACTS_DEBUG="libdandelion-bvh-debug.a libdandelion-ray-debug.a"
    ARTIFACTS_RELEASE="libdandelion-bvh.a libdandelion-ray.a"
elif [ "${BUILD_KIND}" = "release" ]; then
    CMAKE_ROOT="${DANDELION_PATH}"
    ARTIFACTS_DEBUG="dandelion"
    ARTIFACTS_RELEASE="dandelion"
elif [ "${BUILD_KIND}" = "test" ]; then
    CMAKE_ROOT="${DANDELION_PATH}/test"
    ARTIFACTS_DEBUG=""
    ARTIFACTS_RELEASE=""
else
    echo "Please specify a valid build kind (dev, lib, release)" 1>&2
    exit 1
fi

DEBUG_LOG="${BUILD_OUTPUT_PATH}/${OS_NAME}-debug.log"
RELEASE_LOG="${BUILD_OUTPUT_PATH}/${OS_NAME}-release.log"
DEBUG_ARTIFACTS_DIR="${BUILD_OUTPUT_PATH}/${OS_NAME}-debug-artifacts"
RELEASE_ARTIFACTS_DIR="${BUILD_OUTPUT_PATH}/${OS_NAME}-release-artifacts"
touch ${DEBUG_LOG}
touch ${RELEASE_LOG}
chmod 666 ${DEBUG_LOG}
chmod 666 ${RELEASE_LOG}
mkdir -p ${DEBUG_ARTIFACTS_DIR}
mkdir -p ${RELEASE_ARTIFACTS_DIR}

echo "configure dandelion(${BUILD_KIND}) (debug)"
cmake -S ${CMAKE_ROOT} -B ${BUILD_PATH} -DCMAKE_BUILD_TYPE=Debug 2>&1 | tee ${DEBUG_LOG}
echo 'done'
echo "building dandelion(${BUILD_KIND}) (debug)"
cmake --build ${BUILD_PATH} --parallel $(nproc) 2>&1 | tee -a ${DEBUG_LOG}
echo 'done'

for artifact in ${ARTIFACTS_DEBUG}; do
    cp "${BUILD_PATH}/$artifact" ${DEBUG_ARTIFACTS_DIR}/
done

echo "configure dandelion(${BUILD_KIND}) (release)"
cmake -S ${CMAKE_ROOT} -B ${BUILD_PATH} -DCMAKE_BUILD_TYPE=Release 2>&1 | tee ${RELEASE_LOG}
echo 'done'
echo "building dandelion(${BUILD_KIND}) (release)"
cmake --build ${BUILD_PATH} --parallel $(nproc) 2>&1 | tee -a ${RELEASE_LOG}
echo 'done'

for artifact in ${ARTIFACTS_RELEASE}; do
    cp "${BUILD_PATH}/$artifact" ${RELEASE_ARTIFACTS_DIR}/
done
