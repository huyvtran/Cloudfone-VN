# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.4

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/Cellar/cmake/3.4.3/bin/cmake

# The command to remove a file.
RM = /usr/local/Cellar/cmake/3.4.3/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-arm64/Build/linphone

# Utility rule file for liblinphone-git-version.

# Include the progress variables for this target.
include coreapi/CMakeFiles/liblinphone-git-version.dir/progress.make

coreapi/CMakeFiles/liblinphone-git-version:
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-arm64/Build/linphone/coreapi && /usr/local/Cellar/cmake/3.4.3/bin/cmake -DGIT_EXECUTABLE=/usr/bin/git -DLINPHONE_VERSION=3.11.0 -DWORK_DIR=/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/coreapi -DOUTPUT_DIR=/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-arm64/Build/linphone/coreapi -P /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/coreapi/gitversion.cmake

liblinphone-git-version: coreapi/CMakeFiles/liblinphone-git-version
liblinphone-git-version: coreapi/CMakeFiles/liblinphone-git-version.dir/build.make

.PHONY : liblinphone-git-version

# Rule to build all files generated by this target.
coreapi/CMakeFiles/liblinphone-git-version.dir/build: liblinphone-git-version

.PHONY : coreapi/CMakeFiles/liblinphone-git-version.dir/build

coreapi/CMakeFiles/liblinphone-git-version.dir/clean:
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-arm64/Build/linphone/coreapi && $(CMAKE_COMMAND) -P CMakeFiles/liblinphone-git-version.dir/cmake_clean.cmake
.PHONY : coreapi/CMakeFiles/liblinphone-git-version.dir/clean

coreapi/CMakeFiles/liblinphone-git-version.dir/depend:
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-arm64/Build/linphone && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/coreapi /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-arm64/Build/linphone /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-arm64/Build/linphone/coreapi /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-arm64/Build/linphone/coreapi/CMakeFiles/liblinphone-git-version.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : coreapi/CMakeFiles/liblinphone-git-version.dir/depend

