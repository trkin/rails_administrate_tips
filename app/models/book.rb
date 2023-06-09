class Book < ApplicationRecord
  belongs_to :user

  has_many :book_categories
  has_many :reviews, dependent: :destroy

  has_rich_text :content
  has_one_attached :attachment
end
