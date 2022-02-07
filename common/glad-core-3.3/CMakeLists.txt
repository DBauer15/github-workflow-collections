# ======================================================================== #
# Copyright 2018-2021 Qi Wu                                                #
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

project(GLAD LANGUAGES CXX)
cmake_minimum_required(VERSION 3.5)

option(INSTALL_DEV_HEADERS "Whether to install GLAD headers" OFF)

# ┌──────────────────────────────────────────────────────────────────┐
# │  Configurate Packages                                            │
# └──────────────────────────────────────────────────────────────────┘
set(OpenGL_GL_PREFERENCE GLVND)
find_package(OpenGL REQUIRED)

# ┌──────────────────────────────────────────────────────────────────┐
# │  Configure Source Files                                          │
# └──────────────────────────────────────────────────────────────────┘
set(this glad-core-3.3)

# We need to build GLAD as a shared library in order to avoid some 
# wired OpenGL issues. This is probably because both ViDi3D and the
# main framework use OpenGL.
add_library(${this} SHARED src/glad.c)
set_source_files_properties(src/glad.c PROPERTIES LANGUAGE CXX)
set_target_properties(${this} PROPERTIES POSITION_INDEPENDENT_CODE ON)

target_include_directories(${this} 
PUBLIC 
  $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include>
)

target_compile_definitions(${this} 
PUBLIC 
  GLAD_GLAPI_EXPORT
PRIVATE 
  GLAD_GLAPI_EXPORT_BUILD
PUBLIC
  GLAD_GLAPI_CORE_VERSION_MAJOR=3
  GLAD_GLAPI_CORE_VERSION_MINOR=3
)

target_link_libraries(${this} PUBLIC ${CMAKE_DL_LIBS})
if(TARGET OpenGL::OpenGL)
  target_link_libraries(${this} PUBLIC OpenGL::OpenGL)
else()
  target_link_libraries(${this} PUBLIC OpenGL::GL)
endif()
if(TARGET OpenGL::GLU)
  target_link_libraries(${this} PUBLIC OpenGL::GLU)
endif()

# ┌──────────────────────────────────────────────────────────────────┐
# │  Configure Install                                               │
# └──────────────────────────────────────────────────────────────────┘
# 'make install' to the correct locations (provided by GNUInstallDirs).
install(TARGETS ${this} EXPORT ${this}-config) # Windows

if(INSTALL_DEV_HEADERS)

  install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

  # This makes the project importable from the install directory
  # Put config file in per-project dir (name MUST match), can also
  # just go into 'cmake'.
  install(EXPORT ${this}-config
    NAMESPACE glad::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/glad
  )

  # This makes the project importable from the build directory
  export(TARGETS ${this}
    NAMESPACE glad::
    FILE ${CMAKE_INSTALL_LIBDIR}/cmake/glad/${this}-config.cmake
  )

endif()
