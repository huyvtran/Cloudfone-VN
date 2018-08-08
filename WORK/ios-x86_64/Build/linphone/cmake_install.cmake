# Install script for directory: /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone

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
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/share/Linphone/cmake/LinphoneTargets.cmake")
    file(DIFFERENT EXPORT_FILE_CHANGED FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/share/Linphone/cmake/LinphoneTargets.cmake"
         "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/CMakeFiles/Export/share/Linphone/cmake/LinphoneTargets.cmake")
    if(EXPORT_FILE_CHANGED)
      file(GLOB OLD_CONFIG_FILES "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/share/Linphone/cmake/LinphoneTargets-*.cmake")
      if(OLD_CONFIG_FILES)
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/share/Linphone/cmake/LinphoneTargets.cmake\" will be replaced.  Removing files [${OLD_CONFIG_FILES}].")
        file(REMOVE ${OLD_CONFIG_FILES})
      endif()
    endif()
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/Linphone/cmake" TYPE FILE MESSAGE_LAZY FILES "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/CMakeFiles/Export/share/Linphone/cmake/LinphoneTargets.cmake")
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/Linphone/cmake" TYPE FILE MESSAGE_LAZY FILES "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/CMakeFiles/Export/share/Linphone/cmake/LinphoneTargets-release.cmake")
  endif()
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/Linphone/cmake" TYPE FILE MESSAGE_LAZY FILES
    "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/LinphoneConfig.cmake"
    "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/LinphoneConfigVersion.cmake"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/java/cmake_install.cmake")
  include("/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/coreapi/cmake_install.cmake")
  include("/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/include/cmake_install.cmake")
  include("/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/share/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-x86_64/Build/linphone/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
