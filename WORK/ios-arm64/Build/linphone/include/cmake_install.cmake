# Install script for directory: /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/linphone" TYPE FILE MESSAGE_LAZY PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/account_creator.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/address.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/auth_info.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/buffer.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/call.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/call_log.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/call_params.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/call_stats.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/chat.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/conference.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/contactprovider.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/content.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/core.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/core_utils.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/defs.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/dictionary.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/error_info.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/event.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/factory.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/friend.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/friendlist.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/im_encryption_engine.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/im_notif_policy.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/info_message.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/ldapprovider.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/lpconfig.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/misc.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/nat_policy.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/payload_type.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/player.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/presence.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/proxy_config.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/ringtoneplayer.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/sipsetup.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/tunnel.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/types.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/vcard.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/wrapper_utils.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/xmlrpc.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/linphonecore.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/linphonecore_utils.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/linphonefriend.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/linphonepresence.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/linphone_proxy_config.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/include/linphone/linphone_tunnel.h"
    )
endif()

