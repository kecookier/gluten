#!/bin/bash

set -exu

CURRENT_DIR=$(cd "$(dirname "$BASH_SOURCE")"; pwd)

function install_arrow_thirdparty() {
    mkdir -p $CURRENT_DIR/../build/arrow-thirdparty
    wget -q --max-redirect 3 -O - https://s3plus-bj02.sankuai.com/spark-gluten-build/arrow-thirdparty.tar.gz | tar -xz -C "$CURRENT_DIR/../build/arrow-thirdparty" --strip-components=1

    local THIRD_PARTY_ABSOLUTE=$CURRENT_DIR/../build/arrow-thirdparty
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

install_arrow_thirdparty

