
if(BUILD_OPTIX7)
  add_subdirectory(mini_optix7)
endif()

if(BUILD_OSPRAY)
  add_subdirectory(mini_ospray)
endif()

if(BUILD_TORCH)
  add_subdirectory(mini_pytorch)
endif()
