module Admin
  class StatsController < Admin::ApplicationController
    def index
      @stats = {
        books_count: Book.count,
        comments_count: Comment.count,
      }
    end
  end
end
