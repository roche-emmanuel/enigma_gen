CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" GREATER 3.1)
CMAKE_POLICY(SET CMP0054 NEW)
endif()

# The name of this project:
PROJECT(EnigmaGen)
SET(PROJECT_VERSION 1.0)

IF(MSVC)
	# Using MSVC compiler:
	# To build with static runtime linkage:
	SET(CMAKE_CXX_FLAGS "/EHsc /MT") 
	SET(CMAKE_CXX_FLAGS_RELEASE "")
ELSE()
	# Using GCC compiler
	# Note: no-strict-aliasing is needed before boost::thread would break
	# those optimizations if used (enabled with O3).
	SET(CMAKE_CXX_FLAGS "-std=c++11 -fno-strict-aliasing") # -Wall -Wcomment

	# Setup optimization flags:
	SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g")
	SET(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -O3 -s")

	if("${FLAVOR}" STREQUAL "WIN32")
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=i686")	
	endif()

	if("${FLAVOR}" STREQUAL "LINUX64")
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")	
	endif()
ENDIF()

# prepare the source folder:
SET(SRC_DIR ${PROJECT_SOURCE_DIR}/sources)

ADD_SUBDIRECTORY(sources)
