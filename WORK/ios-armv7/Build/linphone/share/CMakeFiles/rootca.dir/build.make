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
CMAKE_BINARY_DIR = /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/linphone

# Utility rule file for rootca.

# Include the progress variables for this target.
include share/CMakeFiles/rootca.dir/progress.make

share/CMakeFiles/rootca: share/rootca.pem


share/rootca.pem:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/linphone/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Generating rootca.pem"
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/linphone/share && /usr/local/Cellar/cmake/3.4.3/bin/cmake -DHTTPS_CA_DIR=/System/Library/OpenSSL -DWORK_DIR=/Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share -DOUTPUT_DIR=/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/linphone/share -P /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share/rootca.cmake

rootca: share/CMakeFiles/rootca
rootca: share/rootca.pem
rootca: share/CMakeFiles/rootca.dir/build.make

.PHONY : rootca

# Rule to build all files generated by this target.
share/CMakeFiles/rootca.dir/build: rootca

.PHONY : share/CMakeFiles/rootca.dir/build

share/CMakeFiles/rootca.dir/clean:
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/linphone/share && $(CMAKE_COMMAND) -P CMakeFiles/rootca.dir/cmake_clean.cmake
.PHONY : share/CMakeFiles/rootca.dir/clean

share/CMakeFiles/rootca.dir/depend:
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/linphone && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone /Users/eicaptain/Desktop/linphone-iphone/submodules/linphone/share /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/linphone /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/linphone/share /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/linphone/share/CMakeFiles/rootca.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : share/CMakeFiles/rootca.dir/depend

