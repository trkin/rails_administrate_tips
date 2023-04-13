# https://github.com/trkin/rails_administrate_tips/tree/main/app/controllers/concerns/book_nestedable.rb
module BookNestedable
  extend ActiveSupport::Concern

  # Under app/controllers/admin/books_controller.rb put
  #
  # def authorized_action?(resource, action)
  #   return true if resource.instance_of? Class # all actions ie index for other classes like User
  #   return true if resource.instance_of? resource_class # all actions for this resource

  #   # For nested resources (like comment) do not allow show and index
  #   %w[new create edit update destroy].include? action.to_s
  # end

  # https://github.com/thoughtbot/administrate/blob/main/app/controllers/administrate/application_controller.rb#L270
  def new_resource
    resource_class.new book: Book.find_by(id: params[:book_id])
  end

  def after_resource_destroyed_path(requested_resource)
    [namespace, requested_resource.book]
  end

  def after_resource_created_path(requested_resource)
    [namespace, requested_resource.book]
  end

  def after_resource_updated_path(requested_resource)
    [namespace, requested_resource.book]
  end

  def authorized_action?(resource, action)
    %w[new create edit update destroy].include? action.to_s
  end
end
