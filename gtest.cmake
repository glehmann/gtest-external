option(USE_SYSTEM_GTEST "Use system installed gtest when set to ON, or build gtest locally when set to OFF" OFF)

if(USE_SYSTEM_GTEST)
  if(${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} VERSION_LESS 2.8)
    message(STATUS "CMake version 2.8 or greater needed to use GTest")
  else()
    find_package(GTest)
  endif()
else()
  include(ExternalProject)

  ExternalProject_Add(
    gtest-external
    URL http://googletest.googlecode.com/files/gtest-1.7.0.zip
    URL_MD5 2d6ec8ccdf5c46b05ba54a9fd1d130d7
    CMAKE_CACHE_ARGS
      -Dgtest_force_shared_crt:BOOL=ON
    INSTALL_COMMAND "")

  ExternalProject_Get_Property(gtest-external binary_dir)
  foreach(lib gtest gtest_main)
    add_library(${lib} IMPORTED STATIC)
    add_dependencies(${lib} gtest-external)
    if(CMAKE_CONFIGURATION_TYPES)
      foreach(type ${CMAKE_CONFIGURATION_TYPES})
        string(TOUPPER ${type} TYPE)
        set_target_properties(${lib} PROPERTIES
          IMPORTED_LOCATION_${TYPE} ${binary_dir}/${type}/${CMAKE_STATIC_LIBRARY_PREFIX}${lib}${CMAKE_STATIC_LIBRARY_SUFFIX})
      endforeach()
    else()
      set_target_properties(${lib} PROPERTIES
        IMPORTED_LOCATION ${binary_dir}/${CMAKE_STATIC_LIBRARY_PREFIX}${lib}${CMAKE_STATIC_LIBRARY_SUFFIX})
    endif()
  endforeach()

  ExternalProject_Get_Property(gtest-external source_dir)
  set(GTEST_INCLUDE_DIRS ${source_dir}/include)
  set(GTEST_LIBRARIES gtest gtest_main)
  set(GTEST_FOUND ON)
endif()
