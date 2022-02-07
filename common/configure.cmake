# ======================================================================== #
# Copyright 2019-2020 Qi Wu                                                #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#     http://www.apache.org/licenses/LICENSE-2.0                           #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
# ======================================================================== #

# ------------------------------------------------------------------
# first, include gdt project to do some general configuration stuff
# (build modes, glut, optix, etc)
# ------------------------------------------------------------------
include_directories(${CMAKE_CURRENT_LIST_DIR})
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)

# ------------------------------------------------------------------
# load external system libraries
# ------------------------------------------------------------------
find_package(OpenMP REQUIRED)
find_package(TBB REQUIRED)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/gdt/cmake")
include(configure_build_type)
if(BUILD_OPTIX7)  
  include(configure_optix)
  mark_as_advanced(CUDA_SDK_ROOT_DIR)
endif(BUILD_OPTIX7)

if(BUILD_OSPRAY)
  find_package(ospray 2.0 REQUIRED)
endif(BUILD_OSPRAY)

if(BUILD_TORCH)
  # https://blog.csdn.net/xzq1207105685/article/details/117400187
  find_package(PythonInterp REQUIRED)
  find_package(Torch REQUIRED)
endif(BUILD_TORCH)

# ------------------------------------------------------------------
# find OpenGL
# ------------------------------------------------------------------
set(OpenGL_GL_PREFERENCE GLVND)
find_package(OpenGL REQUIRED)
if(TARGET OpenGL::OpenGL)
  list(APPEND GFX_LIBRARIES OpenGL::OpenGL)
else()
  list(APPEND GFX_LIBRARIES OpenGL::GL)
endif()
if(TARGET OpenGL::GLU)
  list(APPEND GFX_LIBRARIES OpenGL::GLU)
endif()
if(TARGET OpenGL::GLX)
  list(APPEND GFX_LIBRARIES OpenGL::GLX)
endif()

# ------------------------------------------------------------------
# import gdt submodule
# ------------------------------------------------------------------
include_directories(${CMAKE_CURRENT_LIST_DIR}/gdt)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/gdt EXCLUDE_FROM_ALL)

# ------------------------------------------------------------------
# build glfw + glad
# ------------------------------------------------------------------
set(GLFW_USE_OSMESA OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL ON CACHE BOOL "" FORCE)

set(BUILD_SHARED_LIBS ON)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/glfw-3.3.2 EXCLUDE_FROM_ALL)
set(BUILD_SHARED_LIBS OFF)

mark_as_advanced(
  GLFW_INSTALL
  GLFW_BUILD_DOCS 
  GLFW_BUILD_TESTS 
  GLFW_BUILD_EXAMPLES
  GLFW_USE_OSMESA 
  GLFW_USE_WAYLAND 
  GLFW_VULKAN_STATIC
)

set(INSTALL_DEV_HEADERS ON CACHE BOOL "" FORCE)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/glad-core-3.3 EXCLUDE_FROM_ALL)
add_library(glad::glad ALIAS glad-core-3.3) # make it the global glad
add_library(GLAD::GLAD ALIAS glad-core-3.3) # make it the global glad

list(APPEND GFX_LIBRARIES glfw)
list(APPEND GFX_LIBRARIES glad-core-3.3)

# ------------------------------------------------------------------
# import imgui
# ------------------------------------------------------------------
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/imgui-1.79 EXCLUDE_FROM_ALL)

# ------------------------------------------------------------------
# build rendering app
# ------------------------------------------------------------------
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/glfwapp EXCLUDE_FROM_ALL)

# ------------------------------------------------------------------
# import colormap
# ------------------------------------------------------------------
set(TFNMODULE_INCLUDE ${CMAKE_CURRENT_LIST_DIR}/tfn/colormaps)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/tfn/colormaps)
add_library(tfnmodule ${embedded_colormap})
target_include_directories(tfnmodule PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/tfn/colormaps>
)
