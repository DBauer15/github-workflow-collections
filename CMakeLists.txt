# ======================================================================== #
# Copyright 2022-2022 Qi WU                                                #
#                                                                          #
# Licensed under MIT unless stated otherwise                               #
#                                                                          #
# ======================================================================== #

if(POLICY CMP0048)
  cmake_policy(SET CMP0048 NEW)
endif (POLICY CMP0048)
if(POLICY CMP0054)
  cmake_policy(SET CMP0054 NEW)
endif(POLICY CMP0054)
if(POLICY CMP0104)
  cmake_policy(SET CMP0104 NEW)
endif(POLICY CMP0104)

project(OpenVisRenderer LANGUAGES C CXX CUDA)

cmake_minimum_required(VERSION 3.18)
if(UNIX)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

option(BUILD_OPTIX7   "Build OptiX7 Component"   ON)
option(BUILD_OSPRAY   "Build OSPRay Component"   ON)

include(common/configure.cmake)
add_subdirectory(apps)
