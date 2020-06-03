cmake_minimum_required(VERSION 3.10)

project(RouteGuide)

if(NOT MSVC)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -std=c++11)
else()
    add_definitions(-D_WIN32_WINNT=0x600)
endif()

set(PRJ_NAME route_guide)
set(SRC_GET_DIR ${CMAKE_SOURCE_DIR}/src-gen)
set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)
set(PROTO_DIR ${CMAKE_SOURCE_DIR}/protos)
set(HELPER_FILES ${SRC_DIR}/helper.cc
                 ${SRC_DIR}/helper.h)

# It is assumed that gRPC and all its dependencies are already installed
# on this system, so they can be located by find_package().

# Find Protobuf installation
set(protobuf_MODULE_COMPATIBLE TRUE)
find_package(Protobuf REQUIRED)
message(STATUS Using protobuf ${protobuf_VERSION})

set(_PROTOBUF_LIBPROTOBUF protobuf::libprotobuf)
set(_PROTOBUF_PROTOC $<TARGET_FILE:protobuf::protoc>)

# Find gRPC installation
# Looks for gRPCConfig.cmake file installed by gRPC's cmake installation
find_package(gRPC CONFIG REQUIRED)
message(STATUS Using gRPC ${gRPC_VERSION})

set(_GRPC_GRPCPP_UNSECURE gRPC::grpc++_unsecure)
# Do not get grpc_cpp_plugin from cmake Targets file, but find the one on host
#set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE_gRPC__grpc_cpp_plugin>)
find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)

# Proto file
get_filename_component(rg_proto ${PROTO_DIR}/${PRJ_NAME}.proto ABSOLUTE)
get_filename_component(rg_proto_path ${rg_proto} PATH)

# Generate sources

set(rg_proto_srcs ${SRC_GET_DIR}/${PRJ_NAME}.pb.cc)
set(rg_proto_hdrs ${SRC_GET_DIR}/${PRJ_NAME}.pb.h)
set(rg_grpc_srcs ${SRC_GET_DIR}/${PRJ_NAME}.grpc.pb.cc)
set(rg_grpc_hdrs ${SRC_GET_DIR}/${PRJ_NAME}.grpc.pb.h)
file(MAKE_DIRECTORY ${SRC_GET_DIR})

add_custom_command(
    OUTPUT ${rg_proto_srcs} ${rg_proto_hdrs} ${rg_grpc_srcs} ${rg_grpc_hdrs}
    COMMAND ${_PROTOBUF_PROTOC}
    ARGS --grpc_out ${SRC_GET_DIR}
        --cpp_out ${SRC_GET_DIR}
        -I ${rg_proto_path}
        --plugin=protoc-gen-grpc=${_GRPC_CPP_PLUGIN_EXECUTABLE}
        ${rg_proto}
    DEPENDS ${rg_proto}
)

# Include generated *.pb.h files
include_directories(${SRC_GET_DIR})

# Targets greeter_[async_](client|server)
foreach(_target
    ${PRJ_NAME}_client ${PRJ_NAME}_server)
    add_executable(${_target} ${SRC_DIR}/${_target}.cc
        ${HELPER_FILES}
        ${rg_proto_srcs}
        ${rg_grpc_srcs})
    target_link_libraries(${_target}
        ${_GRPC_GRPCPP_UNSECURE}
        ${_PROTOBUF_LIBPROTOBUF})
endforeach()

# copy the .json db file to the binary folder - route_guide_server depends on it
file(COPY ${SRC_DIR}/route_guide_db.json DESTINATION ${CMAKE_CURRENT_BINARY_DIR})