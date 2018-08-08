# Install script for directory: /Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/x86_64-apple-darwin.ios")
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE MESSAGE_LAZY PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3baserecognizer.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3basetree.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3basetreeadaptor.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3bitset.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3collections.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3commontoken.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3commontree.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3commontreeadaptor.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3commontreenodestream.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3convertutf.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3cyclicdfa.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3debugeventlistener.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3defs.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3encodings.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3errors.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3exception.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3filestream.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3input.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3interfaces.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3intstream.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3lexer.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3memory.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3parser.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3parsetree.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3recognizersharedstate.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3rewritestreams.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3string.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3tokenstream.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/antlr3/runtime/C/include/antlr3treeparser.h"
    )
endif()

