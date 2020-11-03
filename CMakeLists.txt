cmake_minimum_required(VERSION 2.8.7)

project(scribe)

# todo support hdfs
set(SOURCE_FILES src/store.cpp src/store_queue.cpp src/conf.cpp src/file.cpp src/conn_pool.cpp src/scribe_server.cpp src/network_dynamic_config.cpp src/dynamic_bucket_updater.cpp src/env_default.cpp)
set(EXECUTABLE_OUTPUT_PATH ./src)

include_directories(/usr/local/include/thrift)
include_directories(/usr/local/include/thrift/fb303)
include_directories(${PROJECT_SOURCE_DIR})

add_executable(scribed ${SOURCE_FILES})

add_library(scribe STATIC src/gen-cpp/scribe.cpp src/gen-cpp/scribe_types.cpp)
add_library(dynamicbucketupdater STATIC src/gen-cpp/BucketStoreMapping.cpp src/gen-cpp/bucketupdater_types.cpp)

target_link_libraries(scribed boost_system boost_filesystem scribe thrift fb303 dynamicbucketupdater thriftnb event pthread)

# todo -Wall
set (CMAKE_CXX_FLAGS  "-std=c++0x -DHAVE_INTTYPES_H -DHAVE_NETINET_IN_H -DBOOST_FILESYSTEM_VERSION=2")