# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.12

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
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /root/raptor/incubator-brpc/example/echo_c++/myrpc

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /root/raptor/incubator-brpc/example/echo_c++/myrpc/bld

# Include any dependencies generated for this target.
include CMakeFiles/echo_client.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/echo_client.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/echo_client.dir/flags.make

echo.pb.cc: ../echo.proto
echo.pb.cc: /usr/bin/protoc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/root/raptor/incubator-brpc/example/echo_c++/myrpc/bld/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Running C++ protocol buffer compiler on echo.proto"
	/usr/bin/protoc --cpp_out=/root/raptor/incubator-brpc/example/echo_c++/myrpc/bld -I /root/raptor/incubator-brpc/example/echo_c++/myrpc /root/raptor/incubator-brpc/example/echo_c++/myrpc/echo.proto

echo.pb.h: echo.pb.cc
	@$(CMAKE_COMMAND) -E touch_nocreate echo.pb.h

CMakeFiles/echo_client.dir/client.cpp.o: CMakeFiles/echo_client.dir/flags.make
CMakeFiles/echo_client.dir/client.cpp.o: ../client.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/root/raptor/incubator-brpc/example/echo_c++/myrpc/bld/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building CXX object CMakeFiles/echo_client.dir/client.cpp.o"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/echo_client.dir/client.cpp.o -c /root/raptor/incubator-brpc/example/echo_c++/myrpc/client.cpp

CMakeFiles/echo_client.dir/client.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/echo_client.dir/client.cpp.i"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /root/raptor/incubator-brpc/example/echo_c++/myrpc/client.cpp > CMakeFiles/echo_client.dir/client.cpp.i

CMakeFiles/echo_client.dir/client.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/echo_client.dir/client.cpp.s"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /root/raptor/incubator-brpc/example/echo_c++/myrpc/client.cpp -o CMakeFiles/echo_client.dir/client.cpp.s

CMakeFiles/echo_client.dir/echo.pb.cc.o: CMakeFiles/echo_client.dir/flags.make
CMakeFiles/echo_client.dir/echo.pb.cc.o: echo.pb.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/root/raptor/incubator-brpc/example/echo_c++/myrpc/bld/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Building CXX object CMakeFiles/echo_client.dir/echo.pb.cc.o"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/echo_client.dir/echo.pb.cc.o -c /root/raptor/incubator-brpc/example/echo_c++/myrpc/bld/echo.pb.cc

CMakeFiles/echo_client.dir/echo.pb.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/echo_client.dir/echo.pb.cc.i"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /root/raptor/incubator-brpc/example/echo_c++/myrpc/bld/echo.pb.cc > CMakeFiles/echo_client.dir/echo.pb.cc.i

CMakeFiles/echo_client.dir/echo.pb.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/echo_client.dir/echo.pb.cc.s"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /root/raptor/incubator-brpc/example/echo_c++/myrpc/bld/echo.pb.cc -o CMakeFiles/echo_client.dir/echo.pb.cc.s

# Object files for target echo_client
echo_client_OBJECTS = \
"CMakeFiles/echo_client.dir/client.cpp.o" \
"CMakeFiles/echo_client.dir/echo.pb.cc.o"

# External object files for target echo_client
echo_client_EXTERNAL_OBJECTS =

echo_client: CMakeFiles/echo_client.dir/client.cpp.o
echo_client: CMakeFiles/echo_client.dir/echo.pb.cc.o
echo_client: CMakeFiles/echo_client.dir/build.make
echo_client: /usr/local/lib64/libbrpc.a
echo_client: /usr/lib64/libgflags.so
echo_client: /usr/lib64/libprotobuf.so
echo_client: /usr/lib64/libleveldb.so
echo_client: /usr/lib64/libssl.so
echo_client: /usr/lib64/libcrypto.so
echo_client: /usr/lib64/libglog.so
echo_client: /usr/lib64/libgflags.so
echo_client: /usr/lib64/libprotobuf.so
echo_client: /usr/lib64/libleveldb.so
echo_client: /usr/lib64/libssl.so
echo_client: /usr/lib64/libcrypto.so
echo_client: /usr/lib64/libglog.so
echo_client: CMakeFiles/echo_client.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/root/raptor/incubator-brpc/example/echo_c++/myrpc/bld/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Linking CXX executable echo_client"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/echo_client.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/echo_client.dir/build: echo_client

.PHONY : CMakeFiles/echo_client.dir/build

CMakeFiles/echo_client.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/echo_client.dir/cmake_clean.cmake
.PHONY : CMakeFiles/echo_client.dir/clean

CMakeFiles/echo_client.dir/depend: echo.pb.cc
CMakeFiles/echo_client.dir/depend: echo.pb.h
	cd /root/raptor/incubator-brpc/example/echo_c++/myrpc/bld && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /root/raptor/incubator-brpc/example/echo_c++/myrpc /root/raptor/incubator-brpc/example/echo_c++/myrpc /root/raptor/incubator-brpc/example/echo_c++/myrpc/bld /root/raptor/incubator-brpc/example/echo_c++/myrpc/bld /root/raptor/incubator-brpc/example/echo_c++/myrpc/bld/CMakeFiles/echo_client.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/echo_client.dir/depend

