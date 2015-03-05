project(gtestexternal)
cmake_minimum_required(VERSION 2.8)

include(gtest.cmake)
include_directories(${GTEST_INCLUDE_DIRS})

add_executable(dummy_test main.cxx)
target_link_libraries(dummy_test ${GTEST_LIBRARIES})

include(CTest)
add_test(DummyTest dummy_test)
