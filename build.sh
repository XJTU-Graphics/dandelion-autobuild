set -euo pipefail

DEBUG_LOG=/root/build_output/${OS_NAME}-debug.log
RELEASE_LOG=/root/build_output/${OS_NAME}-release.log
touch ${DEBUG_LOG}
touch ${RELEASE_LOG}
chmod 666 ${DEBUG_LOG}
chmod 666 ${RELEASE_LOG}

mkdir build
cd build

echo 'configure dandelion (debug)...'
cmake -S ../dandelion-dev -B . -DCMAKE_BUILD_TYPE=Debug >${DEBUG_LOG} 2>&1
echo 'done'
echo 'building dandelion...'
make -j >>${DEBUG_LOG} 2>&1
echo 'done'

echo 'configure dandelion (release)...'
cmake -S ../dandelion-dev -B . -DCMAKE_BUILD_TYPE=Release >${RELEASE_LOG} 2>&1
echo 'done'
echo 'building dandelion...'
make -j >>${RELEASE_LOG} 2>&1
echo 'done'
