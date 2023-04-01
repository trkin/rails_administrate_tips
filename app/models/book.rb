class Book < ApplicationRecord
  belongs_to :user

  has_many :book_categories
end
