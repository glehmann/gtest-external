#include "gtest/gtest.h"

class DummyTest : public ::testing::Test {
};

TEST_F(DummyTest, ZeroEqual0) {
  EXPECT_EQ(0, 0);
}

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
