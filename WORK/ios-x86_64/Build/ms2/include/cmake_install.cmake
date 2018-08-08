# Install script for directory: /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/mediastreamer2" TYPE FILE MESSAGE_LAZY PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/allfilters.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/bitratecontrol.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/bits_rw.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/devices.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/dsptools.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/dtls_srtp.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/dtmfgen.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/flowcontrol.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/formats.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/ice.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mediastream.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/ms_srtp.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msaudiomixer.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mschanadapter.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mscodecutils.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mscommon.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msconference.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msequalizer.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mseventqueue.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msextdisplay.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msfactory.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msfileplayer.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msfilerec.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msfilter.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msgenericplc.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msinterfaces.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msitc.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msjava.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msjpegwriter.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msogl.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msogl_functions.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msmediaplayer.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msqueue.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msrtp.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mssndcard.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mstee.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msticker.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mstonedetector.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msutils.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msv4l.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msvaddtx.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msvideo.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msvideoout.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msvideopresets.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msvolume.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mswebcam.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/qualityindicator.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/rfc3984.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/stun.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/upnp_igd.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/x11_helper.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/zrtp.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msrtt4103.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msasync.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/msudp.h"
    "/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/mediastreamer2/include/mediastreamer2/mspcapfileplayer.h"
    )
endif()

