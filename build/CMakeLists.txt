cmake_minimum_required(VERSION 2.8)

find_package(LibXml2 REQUIRED)
find_package(ZLIB REQUIRED)
find_package(CURL REQUIRED)

include_directories(${LIBXML2_INCLUDE_DIR})
include_directories(../libdash/libdash/include)
file(GLOB_RECURSE libdash_source ../libdash/libdash/source/*.cpp)

add_library(dash SHARED ${libdash_source})
set_target_properties(dash
    PROPERTIES RESOURCE "../README.md")
target_link_libraries(dash ${CURL_LIBRARIES} ${ZLIB_LIBRARIES} ${LIBXML2_LIBRARIES})

add_custom_target(build_deb
    COMMAND ./create_deb_delivery.sh
)

set(CMAKE_INSTALL_PREFIX "/usr")

install(TARGETS dash 
   LIBRARY DESTINATION lib
   RESOURCE DESTINATION doc/libdash
   COMPONENT libraries)

set(CPACK_PACKAGE_VERSION "1.0.0")
set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME "libdash3.0-ca")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "libdash shared library built by ContentArmor SAS")
set(CPACK_PACKAGE_RELEASE 1)
set(CPACK_PACKAGE_CONTACT "ContentArmor SAS <support@contentarmor.net>")
set(CPACK_PACKAGE_VENDOR "ContentArmor SAS <support@contentarmor.net>")
set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
set(CPACK_STRIP_FILES 1)

set(CPACK_RPM_PACKAGE_LICENSE "LGPL")
set(CPACK_RPM_PACKAGE_DESCRIPTION "libdash is the official reference software of the ISO/IEC MPEG-DASH standard
and is an open-source library that provides an object orient (OO) interface to the MPEG-DASH standard,
developed by Bitmovin (http://www.bitmovin.com).

This package install the libdash shared library generated from https://github.com/contentarmor/libdash
without any modification from ContentArmor SAS.
")
set(CPACK_RPM_PACKAGE_GROUP "Applications/Multimedia")
set(CPACK_RPM_PACKAGE_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
set(CPACK_RPM_PACKAGE_URL "https://github.com/bitmovin/libdash")
set(CPACK_RPM_PACKAGE_RELOCATABLE 1)

include(CPack)
