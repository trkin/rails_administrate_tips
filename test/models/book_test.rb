require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "valid fixture" do
    assert_valid_fixture books
  end
end
