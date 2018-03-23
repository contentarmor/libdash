cmake_minimum_required(VERSION 2.8)

find_package(LibXml2 REQUIRED)
find_package(ZLIB REQUIRED)
find_package(CURL REQUIRED)

include_directories(${LIBXML2_INCLUDE_DIR})
include_directories(../libdash/libdash/include)


file(GLOB_RECURSE libdash_source ../libdash/libdash/source/*.cpp)

add_library(dash SHARED ${libdash_source})
target_link_libraries(dash ${CURL_LIBRARIES} ${ZLIB_LIBRARIES} ${LIBXML2_LIBRARIES})

add_custom_target(build_deb
    COMMAND ./create_deb_delivery.sh
)
