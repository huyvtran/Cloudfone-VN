# Install script for directory: /Users/eicaptain/Desktop/linphone-iphone/submodules/bctoolbox/include

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/arm64-apple-darwin.ios")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/bctoolbox" TYPE FILE MESSAGE_LAZY PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/bctoolbox/include/bctoolbox/crypto.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/bctoolbox/include/bctoolbox/list.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/bctoolbox/include/bctoolbox/logging.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/bctoolbox/include/bctoolbox/map.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/bctoolbox/include/bctoolbox/port.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/bctoolbox/include/bctoolbox/vfs.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/bctoolbox/include/bctoolbox/exception.hh"
    )
endif()

