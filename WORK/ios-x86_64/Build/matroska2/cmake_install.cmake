# Install script for directory: /Users/eicaptain/Desktop/linphone-iphone/submodules/externals/libmatroska-c

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
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/x86_64-apple-darwin.ios/include/corec/config.h")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/x86_64-apple-darwin.ios/include/corec" TYPE FILE MESSAGE_LAZY FILES "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/matroska2/config.h")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/x86_64-apple-darwin.ios/lib/cmake/Matroska2/Matroska2ConfigVersion.cmake;/Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/x86_64-apple-darwin.ios/lib/cmake/Matroska2/Matroska2Config.cmake")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/x86_64-apple-darwin.ios/lib/cmake/Matroska2" TYPE FILE MESSAGE_LAZY FILES
    "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/matroska2/Matroska2ConfigVersion.cmake"
    "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/matroska2/Matroska2Config.cmake"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/matroska2/corec/corec/cmake_install.cmake")
  include("/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/matroska2/libebml2/cmake_install.cmake")
  include("/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/matroska2/libmatroska2/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/matroska2/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
