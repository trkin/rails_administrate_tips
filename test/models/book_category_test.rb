require "test_helper"

class BookCategoryTest < ActiveSupport::TestCase
  test "valid fixture" do
    assert_valid_fixture book_categories
  end
end
