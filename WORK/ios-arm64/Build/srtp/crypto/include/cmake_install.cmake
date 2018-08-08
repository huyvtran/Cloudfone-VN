# Install script for directory: /Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/srtp" TYPE FILE MESSAGE_LAZY PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/aes.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/aes_cbc.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/aes_icm.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/alloc.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/auth.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/cipher.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/crypto.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/crypto_kernel.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/crypto_math.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/crypto_types.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/cryptoalg.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/datatypes.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/err.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/gf2_8.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/hmac.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/integers.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/kernel_compat.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/key.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/null_auth.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/null_cipher.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/prng.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/rand_source.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/rdb.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/rdbx.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/sha1.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/stat.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/externals/srtp/crypto/include/xfm.h"
    )
endif()

