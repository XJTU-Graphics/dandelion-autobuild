set -euo pipefail

DEBUG_LOG=/root/build_output/${OS_NAME}-debug.log
RELEASE_LOG=/root/build_output/${OS_NAME}-release.log
ARTIFACTS_DIR=/root/build_output/${OS_NAME}-artifacts
touch ${DEBUG_LOG}
touch ${RELEASE_LOG}
chmod 666 ${DEBUG_LOG}
chmod 666 ${RELEASE_LOG}
mkdir -p ${ARTIFACTS_DIR}

mkdir build
cd build

echo 'configure dandelion (debug)...'
cmake -S ../dandelion-dev -B . -DCMAKE_BUILD_TYPE=Debug 2>&1 | tee ${DEBUG_LOG}
echo 'done'
echo 'building dandelion...'
cmake --build . --parallel 8 2>&1 | tee -a ${DEBUG_LOG}
echo 'done'

cp ./dandelion ${ARTIFACTS_DIR}/dandelion-debug

echo 'configure dandelion (release)...'
cmake -S ../dandelion-dev -B . -DCMAKE_BUILD_TYPE=Release 2>&1 | tee ${RELEASE_LOG}
echo 'done'
echo 'building dandelion...'
cmake --build . --parallel 8 2>&1 | tee -a ${RELEASE_LOG}
echo 'done'

cp ./dandelion ${ARTIFACTS_DIR}/dandelion-release
