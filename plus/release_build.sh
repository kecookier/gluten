#!/bin/bash
##############################
# fast build libgluten.so/libarrow.so/libvelox.so
# default target dir: ${GLUTEN_DIR}/cpp/build/Release/
# default only release build

#set -exu
set -eu


CURRENT_DIR=$(cd "$(dirname "$BASH_SOURCE")"; pwd)
GLUTEN_DIR="$CURRENT_DIR/.."

PACK=false

for arg in "$@"
do
    case $arg in
        -p)
        PACK=true
        shift # Remove argument name from processing
        ;;
	      *)
        OTHER_ARGUMENTS+=("$1")
        shift # Remove generic argument from processing
        ;;
    esac
done

${GLUTEN_DIR}/dev/builddeps-veloxbe.sh --enable_hdfs=ON --enable_isal=OFF --build_type=Release --run_setup_script=OFF

if [ $PACK == 'true' ]; then
    cd ${GLUTEN_DIR}
    mvn clean package -Denforcer.skip=true -Pbackends-velox -Pspark-3.0 -Phadoop-2.7.1 -DskipTests
fi
