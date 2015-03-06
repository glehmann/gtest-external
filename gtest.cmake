option(USE_SYSTEM_GTEST "Use system installed gtest when set to ON, or build gtest locally when set to OFF" OFF)

if(USE_SYSTEM_GTEST)
  find_package(GTest)
else()
  include(ExternalProject)

  # the binary dir must be know before creating the external project in order
  # to pass the byproducts
  set(prefix "${CMAKE_CURRENT_BINARY_DIR}/gtest-external")
  set(binary_dir "${prefix}/src/gtest-external-build")

  set(byproducts)
  foreach(lib gtest gtest_main)
    if(CMAKE_CONFIGURATION_TYPES)
      set(${lib}_properties)
      foreach(type ${CMAKE_CONFIGURATION_TYPES})
        string(TOUPPER ${type} TYPE)
        set(file ${binary_dir}/${type}/${CMAKE_STATIC_LIBRARY_PREFIX}${lib}${CMAKE_STATIC_LIBRARY_SUFFIX})
        list(APPEND ${lib}_properties IMPORTED_LOCATION_${TYPE} ${file})
        list(APPEND byproducts ${file})
      endforeach()
    else()
      set(file ${binary_dir}/${CMAKE_STATIC_LIBRARY_PREFIX}${lib}${CMAKE_STATIC_LIBRARY_SUFFIX})
      set(${lib}_properties IMPORTED_LOCATION ${file})
      list(APPEND byproducts ${file})
    endif()
  endforeach()

  set(build_byproducts)
  if(${CMAKE_VERSION} VERSION_LESS 3.2)
    if(CMAKE_GENERATOR MATCHES "Ninja")
      message(WARNING "Building GTest with Ninja has known issues with CMake older than 3.2")
    endif()
  else()
    set(build_byproducts BUILD_BYPRODUCTS ${byproducts})
  endif()

  ExternalProject_Add(
    gtest-external
    URL http://googletest.googlecode.com/files/gtest-1.7.0.zip
    URL_MD5 2d6ec8ccdf5c46b05ba54a9fd1d130d7
    PREFIX ${prefix}
    BINARY_DIR ${binary_dir}
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
      -DCMAKE_CXX_FLAGS_MINSIZEREL:STRING=${CMAKE_CXX_FLAGS_MINSIZEREL}
      -DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
      -DCMAKE_CXX_FLAGS_RELWITHDEBINFO:STRING=${CMAKE_CXX_FLAGS_RELWITHDEBINFO}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
      -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}
      -DCMAKE_C_FLAGS_MINSIZEREL:STRING=${CMAKE_C_FLAGS_MINSIZEREL}
      -DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}
      -DCMAKE_C_FLAGS_RELWITHDEBINFO:STRING=${CMAKE_C_FLAGS_RELWITHDEBINFO}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -Dgtest_force_shared_crt:BOOL=ON
    ${build_byproducts}
    INSTALL_COMMAND "")

  foreach(lib gtest gtest_main)
    add_library(${lib} IMPORTED STATIC)
    add_dependencies(${lib} gtest-external)
    set_target_properties(${lib} PROPERTIES ${${lib}_properties})
  endforeach()

  ExternalProject_Get_Property(gtest-external source_dir)
  set(GTEST_INCLUDE_DIRS ${source_dir}/include)
  set(GTEST_LIBRARIES gtest gtest_main)
  set(GTEST_FOUND ON)
endif()
