#!/bin/bash
####################################################################################################
#  The main function of this script is to allow developers to build the environment with one click #
#  Recommended commands for first-time installation:                                               #
#  ./dev/buildbundle-veloxbe.sh                                                            #
####################################################################################################
set -exu

CURRENT_DIR=$(cd "$(dirname "$BASH_SOURCE")"; pwd)
GLUTEN_DIR="$CURRENT_DIR/.."
BUILD_TYPE=Release
BUILD_TESTS=OFF
BUILD_EXAMPLES=OFF
BUILD_BENCHMARKS=OFF
BUILD_JEMALLOC=OFF
BUILD_PROTOBUF=ON
ENABLE_QAT=OFF
ENABLE_IAA=OFF
ENABLE_HBM=OFF
ENABLE_S3=OFF
ENABLE_HDFS=OFF
ENABLE_EP_CACHE=OFF
SKIP_BUILD_EP=OFF
ARROW_ENABLE_CUSTOM_CODEC=OFF
ENABLE_VCPKG=OFF
ENABLE_ISAL=OFF
RUN_SETUP_SCRIPT=ON

for arg in "$@"
do
    case $arg in
        --build_type=*)
        BUILD_TYPE=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --build_tests=*)
        BUILD_TESTS=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --build_examples=*)
        BUILD_EXAMPLES=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --build_benchmarks=*)
        BUILD_BENCHMARKS=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --build_jemalloc=*)
        BUILD_JEMALLOC=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --enable_qat=*)
        ENABLE_QAT=("${arg#*=}")
        ARROW_ENABLE_CUSTOM_CODEC=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --enable_iaa=*)
        ENABLE_IAA=("${arg#*=}")
        ARROW_ENABLE_CUSTOM_CODEC=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --enable_hbm=*)
        ENABLE_HBM=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --build_protobuf=*)
        BUILD_PROTOBUF=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --enable_s3=*)
        ENABLE_S3=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --enable_hdfs=*)
        ENABLE_HDFS=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --enable_ep_cache=*)
        ENABLE_EP_CACHE=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --skip_build_ep=*)
        SKIP_BUILD_EP=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --enable_vcpkg=*)
        ENABLE_VCPKG=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --enable_isal=*)
        ENABLE_ISAL=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
        --run_setup_script=*)
        RUN_SETUP_SCRIPT=("${arg#*=}")
        shift # Remove argument name from processing
        ;;
	      *)
        OTHER_ARGUMENTS+=("$1")
        shift # Remove generic argument from processing
        ;;
    esac
done

if [ "$ENABLE_VCPKG" = "ON" ]; then
    # vcpkg will install static depends and init build environment
    envs="$("$GLUTEN_DIR/dev/vcpkg/init.sh")"
    eval "$envs"
fi

function install_arrow_thirdparty() {
    mkdir -p arrow-thirdparty
    wget -q --max-redirect 3 -O - https://s3plus-bj02.sankuai.com/spark-gluten-build/arrow-thirdparty.tar.gz | tar -xz -C "arrow-thirdparty" --strip-components=1

    local THIRD_PARTY_ABSOLUTE=$GLUTEN_DIR/ep/build-arrow/src/arrow-thirdparty
    # Environment variables for offline Arrow build
    export ARROW_ABSL_URL=${THIRD_PARTY_ABSOLUTE}/absl-20211102.0.tar.gz
    export ARROW_AWS_C_AUTH_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-auth-v0.6.22.tar.gz
    export ARROW_AWS_C_CAL_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-cal-v0.5.20.tar.gz
    export ARROW_AWS_C_COMMON_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-common-v0.8.9.tar.gz
    export ARROW_AWS_C_COMPRESSION_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-compression-v0.2.16.tar.gz
    export ARROW_AWS_C_EVENT_STREAM_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-event-stream-v0.2.18.tar.gz
    export ARROW_AWS_C_HTTP_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-http-v0.7.3.tar.gz
    export ARROW_AWS_C_IO_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-io-v0.13.14.tar.gz
    export ARROW_AWS_C_MQTT_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-mqtt-v0.8.4.tar.gz
    export ARROW_AWS_C_S3_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-s3-v0.2.3.tar.gz
    export ARROW_AWS_C_SDKUTILS_URL=${THIRD_PARTY_ABSOLUTE}/aws-c-sdkutils-v0.1.6.tar.gz
    export ARROW_AWS_CHECKSUMS_URL=${THIRD_PARTY_ABSOLUTE}/aws-checksums-v0.1.13.tar.gz
    export ARROW_AWS_CRT_CPP_URL=${THIRD_PARTY_ABSOLUTE}/aws-crt-cpp-v0.18.16.tar.gz
    export ARROW_AWS_LC_URL=${THIRD_PARTY_ABSOLUTE}/aws-lc-v1.3.0.tar.gz
    export ARROW_AWSSDK_URL=${THIRD_PARTY_ABSOLUTE}/aws-sdk-cpp-1.10.55.tar.gz
    export ARROW_BOOST_URL=${THIRD_PARTY_ABSOLUTE}/boost-1.81.0.tar.gz
    export ARROW_BROTLI_URL=${THIRD_PARTY_ABSOLUTE}/brotli-v1.0.9.tar.gz
    export ARROW_BZIP2_URL=${THIRD_PARTY_ABSOLUTE}/bzip2-1.0.8.tar.gz
    export ARROW_CARES_URL=${THIRD_PARTY_ABSOLUTE}/cares-1.17.2.tar.gz
    export ARROW_CRC32C_URL=${THIRD_PARTY_ABSOLUTE}/crc32c-1.1.2.tar.gz
    export ARROW_GBENCHMARK_URL=${THIRD_PARTY_ABSOLUTE}/gbenchmark-v1.7.1.tar.gz
    export ARROW_GFLAGS_URL=${THIRD_PARTY_ABSOLUTE}/gflags-v2.2.2.tar.gz
    export ARROW_GLOG_URL=${THIRD_PARTY_ABSOLUTE}/glog-v0.5.0.tar.gz
    export ARROW_GOOGLE_CLOUD_CPP_URL=${THIRD_PARTY_ABSOLUTE}/google-cloud-cpp-v2.8.0.tar.gz
    export ARROW_GRPC_URL=${THIRD_PARTY_ABSOLUTE}/grpc-v1.46.3.tar.gz
    export ARROW_GTEST_URL=${THIRD_PARTY_ABSOLUTE}/gtest-1.11.0.tar.gz
    export ARROW_JEMALLOC_URL=${THIRD_PARTY_ABSOLUTE}/jemalloc-5.3.0.tar.bz2
    export ARROW_LZ4_URL=${THIRD_PARTY_ABSOLUTE}/lz4-v1.9.4.tar.gz
    export ARROW_MIMALLOC_URL=${THIRD_PARTY_ABSOLUTE}/mimalloc-v2.0.6.tar.gz
    export ARROW_NLOHMANN_JSON_URL=${THIRD_PARTY_ABSOLUTE}/nlohmann-json-v3.10.5.tar.gz
    export ARROW_OPENTELEMETRY_URL=${THIRD_PARTY_ABSOLUTE}/opentelemetry-cpp-v1.8.1.tar.gz
    export ARROW_OPENTELEMETRY_PROTO_URL=${THIRD_PARTY_ABSOLUTE}/opentelemetry-proto-v0.17.0.tar.gz
    export ARROW_ORC_URL=${THIRD_PARTY_ABSOLUTE}/orc-1.8.3.tar.gz
    export ARROW_PROTOBUF_URL=${THIRD_PARTY_ABSOLUTE}/protobuf-v21.3.tar.gz
    export ARROW_RAPIDJSON_URL=${THIRD_PARTY_ABSOLUTE}/rapidjson-232389d4f1012dddec4ef84861face2d2ba85709.tar.gz
    export ARROW_RE2_URL=${THIRD_PARTY_ABSOLUTE}/re2-2022-06-01.tar.gz
    export ARROW_S2N_TLS_URL=${THIRD_PARTY_ABSOLUTE}/s2n-v1.3.35.tar.gz
    export ARROW_SNAPPY_URL=${THIRD_PARTY_ABSOLUTE}/snappy-1.1.9.tar.gz
    export ARROW_THRIFT_URL=${THIRD_PARTY_ABSOLUTE}/thrift-0.16.0.tar.gz
    export ARROW_UCX_URL=${THIRD_PARTY_ABSOLUTE}/ucx-1.12.1.tar.gz
    export ARROW_UTF8PROC_URL=${THIRD_PARTY_ABSOLUTE}/utf8proc-v2.7.0.tar.gz
    export ARROW_XSIMD_URL=${THIRD_PARTY_ABSOLUTE}/xsimd-9.0.1.tar.gz
    export ARROW_ZLIB_URL=${THIRD_PARTY_ABSOLUTE}/zlib-1.2.13.tar.gz
    export ARROW_ZSTD_URL=${THIRD_PARTY_ABSOLUTE}/zstd-1.5.5.tar.gz
}

##install arrow
# if [ "$SKIP_BUILD_EP" != "ON" ]; then
#     cd $GLUTEN_DIR/ep/build-arrow/src
#     ./get_arrow.sh --enable_custom_codec=$ARROW_ENABLE_CUSTOM_CODEC --enable_internal_arrow=ON
#     install_arrow_thirdparty
#     ./build_arrow.sh --build_type=$BUILD_TYPE --build_tests=$BUILD_TESTS --build_benchmarks=$BUILD_BENCHMARKS \
#                              --enable_ep_cache=$ENABLE_EP_CACHE
# fi

##install velox
if [ "$SKIP_BUILD_EP" != "ON" ]; then
    cd $GLUTEN_DIR/ep/build-velox/src
    ./get_velox.sh --enable_hdfs=$ENABLE_HDFS --build_protobuf=$BUILD_PROTOBUF --enable_s3=$ENABLE_S3
    ./build_velox.sh --enable_s3=$ENABLE_S3 --build_type=$BUILD_TYPE --enable_hdfs=$ENABLE_HDFS \
                   --enable_ep_cache=$ENABLE_EP_CACHE --build_tests=$BUILD_TESTS --build_benchmarks=$BUILD_BENCHMARKS \
                   --enable_isal=$ENABLE_ISAL  --run_setup_script=$RUN_SETUP_SCRIPT
                #    --velox_dependency_source=SYSTEM
fi

## compile gluten cpp
cd $GLUTEN_DIR/cpp
rm -rf build
mkdir build
cd build
cmake -DBUILD_VELOX_BACKEND=ON -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DBUILD_TESTS=$BUILD_TESTS -DBUILD_EXAMPLES=$BUILD_EXAMPLES -DBUILD_BENCHMARKS=$BUILD_BENCHMARKS -DBUILD_JEMALLOC=$BUILD_JEMALLOC \
      -DENABLE_HBM=$ENABLE_HBM -DENABLE_QAT=$ENABLE_QAT -DENABLE_IAA=$ENABLE_IAA -DENABLE_S3=$ENABLE_S3 -DENABLE_HDFS=$ENABLE_HDFS \
      -DENABLE_ISAL=$ENABLE_ISAL ..
make -j

## bundle jar
cd $GLUTEN_DIR 
mvn clean package -Denforcer.skip=true -Pbackends-velox -Pspark-3.0 -Phadoop-2.7.1 -DskipTests
