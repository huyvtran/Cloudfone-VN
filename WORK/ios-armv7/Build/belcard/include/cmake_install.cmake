# Install script for directory: /Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/armv7-apple-darwin.ios")
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/belcard" TYPE FILE MESSAGE_LAZY PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_addressing.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_communication.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_general.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_geographical.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_identification.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_params.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_property.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_security.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_calendar.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_explanatory.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_generic.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_organizational.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_parser.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_rfc6474.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/belcard_utils.hpp"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/include/belcard/vcard_grammar.hpp"
    )
endif()

