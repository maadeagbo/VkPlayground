cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

###########################################################################

project(VkPlayground VERSION 1.0.0 LANGUAGES CXX C)

############################################################################

# set release or debug builds
if(CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_CONFIGURATION_TYPES Release RelWithDebInfo MinSizeRel Debug)
  set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES}" CACHE STRING
      "Reset the configurations"
      FORCE)
endif(CMAKE_CONFIGURATION_TYPES)

# set output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)

foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${PROJECT_SOURCE_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${PROJECT_SOURCE_DIR}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${PROJECT_SOURCE_DIR}/lib)
endforeach(OUTPUTCONFIG CMAKE_CONFIGURATION_TYPES)

##########################################################################

set(CMAKE_CXX_STANDARD 14)

if(MSVC AND NOT USE_CLANG)
  set(CMAKE_C_STANDARD 99)
else()
  set(CMAKE_C_STANDARD 11)
endif(MSVC AND NOT USE_CLANG)

###########################################################################

# lua integration

add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/lua_53)

find_path(LUA_PATH lua.hpp PATHS ${CMAKE_CURRENT_LIST_DIR}/lua_53/src)

if(NOT LUA_PATH)
  message(FATAL_ERROR "Lua include not found")
endif()

set(MY_ROOT_PATH ${CMAKE_CURRENT_LIST_DIR})

if(MSVC)
  string(REGEX REPLACE "/" "\\\\\\\\" MY_ROOT_PATH ${MY_ROOT_PATH})

  file(WRITE ${CMAKE_CURRENT_LIST_DIR}/Scripts/lua_config.lua
        "-- Add Root directory to package path\n"
        "package.path = package.path .. \";${CMAKE_CURRENT_LIST_DIR}/?.lua\"\n"
		"OS_SLASH			= \"\\\\\"\n"
        "ROOT_DIR     = \"${MY_ROOT_PATH}\"\n"
        "SHADER_DIR   = \"${MY_ROOT_PATH}\\\\Shaders\"\n"
        "MESH_DIR     = \"${MY_ROOT_PATH}\\\\Meshes\"\n"
        "TEX_DIR      = \"${MY_ROOT_PATH}\\\\Textures\"\n"
		"MATERIAL_DIR = \"${MY_ROOT_PATH}\\\\Materials\"\n"
        "SCRIPT_DIR   = \"${MY_ROOT_PATH}\\\\Scripts\"\n")
	
else()

  file(WRITE ${CMAKE_CURRENT_LIST_DIR}/Scripts/lua_config.lua
        "-- Add Root directory to package path\n"
        "package.path = package.path .. \";${CMAKE_CURRENT_LIST_DIR}/?.lua\"\n"
		"OS_SLASH     = \"/\"\n"
        "ROOT_DIR     = \"${CMAKE_CURRENT_LIST_DIR}\"\n"
        "SHADER_DIR   = \"${CMAKE_CURRENT_LIST_DIR}/Shaders\"\n"
        "MESH_DIR     = \"${CMAKE_CURRENT_LIST_DIR}/Meshes\"\n"
        "TEX_DIR      = \"${CMAKE_CURRENT_LIST_DIR}/Textures\"\n"
		"MATERIAL_DIR = \"${CMAKE_CURRENT_LIST_DIR}/Materials\"\n"
        "SCRIPT_DIR   = \"${CMAKE_CURRENT_LIST_DIR}/Scripts\"\n")

endif(MSVC)

###########################################################################

# set vulkan validation layer only in debug builds
option(VALIDATE_VK "Use debug validation layer in build" ON)

option(NON_PROFILE_BUILD "Allow all profiling logic" ON)

option(TURN_ON_DEBUG_HELPERS "Turn on all asserts" ON)

option(IN_EDITOR_CONFIG "Build editor solution and turn on editor defines" OFF)

if(TURN_ON_DEBUG_HELPERS)
  set(DEBUG_ON "Turn on asserts globally" ON)
endif(TURN_ON_DEBUG_HELPERS)

# print messages
option(VEBOSE "Print out all server information to stdout" OFF)

if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/Config.h)
  file(REMOVE ${CMAKE_CURRENT_LIST_DIR}/src/Config.h)
endif(EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/Config.h)

# configure a header to pass CMake settings to the source code
configure_file ("${CMAKE_CURRENT_LIST_DIR}/src/Config.h.in"
                "${CMAKE_CURRENT_LIST_DIR}/src/Config.h"
)

###########################################################################

include(FindPackageHandleStandardArgs)
find_package(Vulkan REQUIRED)
message("Vulkan library directory: ${Vulkan_LIBRARIES}")

set(VKPG_SOURCE
	"src/Config.h"
)

if(MSVC)
	set(VKPG_SOURCE ${VKPG_SOURCE}
		#"src/System/WindowInterfaceWin32.c"
	)
else()
	set(VKPG_SOURCE ${VKPG_SOURCE}
		#"src/System/WindowInterfaceLinux.c"
	)
endif(MSVC)

##########################################################################

if(NOT MSVC)
  add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/backtrace)
endif(NOT MSVC)

###########################################################################

# Engine build
if(MSVC)
	# add shaders to build
	file(GLOB_RECURSE SHADER_SOURCES
		LIST_DIRECTORIES false
		"Shaders/*.vert"
		"Shaders/*.frag"
		"Shaders/*.geom"
		"Shaders/*.comp"
		"Shaders/*.h")

	# add lua scripts to build
	file(GLOB_RECURSE LUA_SCRIPT_SOURCES
		LIST_DIRECTORIES false
		"Scripts/*.lua")

	set(CMAKE_MFC_FLAG 2) # 1 for static linkage, 2 for shared dll linkage
	add_executable(vk_playground WIN32
		"src/main.cpp" 
		${VKPG_SOURCE}
		${SHADER_SOURCES}
		${LUA_SCRIPT_SOURCES})
	
else()

	add_executable(vk_playground 
		"src/main.cpp" 
		${VKPG_SOURCE}
		${DEMO_PROJECT_FILES})

endif(MSVC)

# setup IDE folders
source_group(TREE "..\\" FILES ${VKPG_SOURCE} ${VKPG_HEADERS} ${SHADER_SOURCES} ${LUA_SCRIPT_SOURCES} ${DEMO_PROJECT_FILES})

target_compile_definitions(vk_playground PRIVATE "_CRT_SECURE_NO_WARNINGS" CJSON_HIDE_SYMBOLS)

target_compile_options(vk_playground PRIVATE ${OpenMP_CXX_FLAGS} $<$<CXX_COMPILER_ID:MSVC>: /W4 /WX /Qvec-report:2                                                                                    $<$<BOOL:TURN_ON_DEBUG_HELPERS>:/Fm /Zi> $<$<CONFIG:DEBUG>:/Od> $<$<CONFIG:RELEASE>:/O2> $<$<CONFIG:MINSIZEREL>:/Os> $<$<CONFIG:RELWITHDEBINFO>:/O1>>)
target_compile_options(vk_playground PRIVATE ${OpenMP_C_FLAGS}   $<$<C_COMPILER_ID:MSVC>:   /W4 /WX /Qvec-report:2                                                                                    $<$<BOOL:TURN_ON_DEBUG_HELPERS>:/Fm /Zi> $<$<CONFIG:DEBUG>:/Od> $<$<CONFIG:RELEASE>:/O2> $<$<CONFIG:MINSIZEREL>:/Os> $<$<CONFIG:RELWITHDEBINFO>:/O1>>)
target_compile_options(vk_playground PRIVATE ${OpenMP_CXX_FLAGS} $<$<CXX_COMPILER_ID:GNU>:  -Wall -Wextra -Wno-missing-field-initializers -Werror -rdynamic -no-pie -fPIC -ftree-vectorize -fopt-info-vec-optimized -fopt-info-vec-missed     $<$<BOOL:TURN_ON_DEBUG_HELPERS>:-g> $<$<CONFIG:RELEASE>:-O2> $<$<CONFIG:MINSIZEREL>:-Os> $<$<CONFIG:RELWITHDEBINFO>:-O2> >)
target_compile_options(vk_playground PRIVATE ${OpenMP_C_FLAGS}   $<$<C_COMPILER_ID:GNU>:    -Wall -Wextra -Wno-missing-field-initializers -Werror -rdynamic -no-pie -fPIC -ftree-vectorize -fopt-info-vec-optimized -fopt-info-vec-missed     $<$<BOOL:TURN_ON_DEBUG_HELPERS>:-g> $<$<CONFIG:RELEASE>:-O2> $<$<CONFIG:MINSIZEREL>:-Os> $<$<CONFIG:RELWITHDEBINFO>:-O2> >)
target_compile_options(vk_playground PRIVATE ${OpenMP_CXX_FLAGS} $<$<CXX_COMPILER_ID:CLANG>:-Wall -Wextra -Wno-missing-field-initializers -Werror -rdynamic -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize $<$<BOOL:TURN_ON_DEBUG_HELPERS>:-g> $<$<CONFIG:RELEASE>:-O2> $<$<CONFIG:MINSIZEREL>:-Os> $<$<CONFIG:RELWITHDEBINFO>:-O2> >)
target_compile_options(vk_playground PRIVATE ${OpenMP_C_FLAGS}   $<$<C_COMPILER_ID:CLANG>:  -Wall -Wextra -Wno-missing-field-initializers -Werror -rdynamic -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize $<$<BOOL:TURN_ON_DEBUG_HELPERS>:-g> $<$<CONFIG:RELEASE>:-O2> $<$<CONFIG:MINSIZEREL>:-Os> $<$<CONFIG:RELWITHDEBINFO>:-O2> >)
                                                                                                                                                                                                
target_link_libraries(vk_playground PRIVATE $<$<C_COMPILER_ID:MSVC>:ws2_32> "${Vulkan_LIBRARIES}" liblua $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:backtrace> $<$<CXX_COMPILER_ID:MSVC>:dbghelp>)

if(NOT MSVC)
  target_link_libraries(vk_playground PRIVATE "-Wl,--as-needed -lX11 -ldl -lxcb -lxcb-icccm -lxcb-keysyms -lxcb-xinput")
endif(NOT MSVC)

target_include_directories(vk_playground PRIVATE
  "${CMAKE_CURRENT_LIST_DIR}/src"
  "${CMAKE_CURRENT_LIST_DIR}/backtrace"
  #"${CMAKE_CURRENT_LIST_DIR}/imgui"
  "${Vulkan_INCLUDE_DIRS}"
  "${LUA_INCLUDE_DIR}"
)

# For json file off project structure
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

###########################################################################

# build a CPack driven installer package
include (InstallRequiredSystemLibraries)
#set (CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/License.txt")
set (CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set (CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
include (CPack)

###########################################################################

# set visual studio startup project
set_property(DIRECTORY ${PROJECT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT vk_playground)
