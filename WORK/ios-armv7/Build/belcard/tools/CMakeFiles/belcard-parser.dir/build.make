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
CMAKE_SOURCE_DIR = /Users/eicaptain/Desktop/linphone-iphone/submodules/belcard

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard

# Include any dependencies generated for this target.
include tools/CMakeFiles/belcard-parser.dir/depend.make

# Include the progress variables for this target.
include tools/CMakeFiles/belcard-parser.dir/progress.make

# Include the compile flags for this target's objects.
include tools/CMakeFiles/belcard-parser.dir/flags.make

tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o: tools/CMakeFiles/belcard-parser.dir/flags.make
tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o: /Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/tools/belcard-parser.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o"
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard/tools && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++  --target=armv7-apple-darwin  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS)  -Wall -Wuninitialized -Wno-error=deprecated-declarations -Wno-error=unknown-warning-option -Qunused-arguments -Wno-tautological-compare -Wno-unused-function -Wno-array-bounds -Werror -Wextra -Wno-unused-parameter -fno-strict-aliasing -std=c++11 -stdlib=libc++ -o CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o -c /Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/tools/belcard-parser.cpp

tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/belcard-parser.dir/belcard-parser.cpp.i"
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard/tools && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++  --target=armv7-apple-darwin $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS)  -Wall -Wuninitialized -Wno-error=deprecated-declarations -Wno-error=unknown-warning-option -Qunused-arguments -Wno-tautological-compare -Wno-unused-function -Wno-array-bounds -Werror -Wextra -Wno-unused-parameter -fno-strict-aliasing -std=c++11 -stdlib=libc++ -E /Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/tools/belcard-parser.cpp > CMakeFiles/belcard-parser.dir/belcard-parser.cpp.i

tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/belcard-parser.dir/belcard-parser.cpp.s"
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard/tools && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++  --target=armv7-apple-darwin $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS)  -Wall -Wuninitialized -Wno-error=deprecated-declarations -Wno-error=unknown-warning-option -Qunused-arguments -Wno-tautological-compare -Wno-unused-function -Wno-array-bounds -Werror -Wextra -Wno-unused-parameter -fno-strict-aliasing -std=c++11 -stdlib=libc++ -S /Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/tools/belcard-parser.cpp -o CMakeFiles/belcard-parser.dir/belcard-parser.cpp.s

tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o.requires:

.PHONY : tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o.requires

tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o.provides: tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o.requires
	$(MAKE) -f tools/CMakeFiles/belcard-parser.dir/build.make tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o.provides.build
.PHONY : tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o.provides

tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o.provides.build: tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o


# Object files for target belcard-parser
belcard__parser_OBJECTS = \
"CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o"

# External object files for target belcard-parser
belcard__parser_EXTERNAL_OBJECTS =

tools/belcard-parser: tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o
tools/belcard-parser: tools/CMakeFiles/belcard-parser.dir/build.make
tools/belcard-parser: src/libbelcard.a
tools/belcard-parser: /Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/armv7-apple-darwin.ios/lib/libbelr.a
tools/belcard-parser: /Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/armv7-apple-darwin.ios/lib/libbctoolbox.a
tools/belcard-parser: /Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/armv7-apple-darwin.ios/lib/libmbedtls.a
tools/belcard-parser: /Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/armv7-apple-darwin.ios/lib/libmbedx509.a
tools/belcard-parser: /Users/eicaptain/Desktop/linphone-iphone/liblinphone-sdk/armv7-apple-darwin.ios/lib/libmbedcrypto.a
tools/belcard-parser: tools/CMakeFiles/belcard-parser.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable belcard-parser"
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard/tools && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/belcard-parser.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
tools/CMakeFiles/belcard-parser.dir/build: tools/belcard-parser

.PHONY : tools/CMakeFiles/belcard-parser.dir/build

tools/CMakeFiles/belcard-parser.dir/requires: tools/CMakeFiles/belcard-parser.dir/belcard-parser.cpp.o.requires

.PHONY : tools/CMakeFiles/belcard-parser.dir/requires

tools/CMakeFiles/belcard-parser.dir/clean:
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard/tools && $(CMAKE_COMMAND) -P CMakeFiles/belcard-parser.dir/cmake_clean.cmake
.PHONY : tools/CMakeFiles/belcard-parser.dir/clean

tools/CMakeFiles/belcard-parser.dir/depend:
	cd /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/eicaptain/Desktop/linphone-iphone/submodules/belcard /Users/eicaptain/Desktop/linphone-iphone/submodules/belcard/tools /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard/tools /Users/eicaptain/Desktop/linphone-iphone/WORK/ios-armv7/Build/belcard/tools/CMakeFiles/belcard-parser.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : tools/CMakeFiles/belcard-parser.dir/depend

