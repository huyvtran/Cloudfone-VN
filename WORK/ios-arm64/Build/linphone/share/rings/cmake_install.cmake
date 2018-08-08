# Install script for directory: /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share/rings

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/./share/sounds/linphone/rings" TYPE FILE MESSAGE_LAZY PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share/rings/oldphone-mono.wav"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share/rings/four_hands_together.mkv"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share/rings/house_keeping.mkv"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share/rings/its_a_game.mkv"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share/rings/leaving_dreams.mkv"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share/rings/notes_of_the_optimistic.mkv"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share/rings/soft_as_snow.mkv"
    )
endif()

