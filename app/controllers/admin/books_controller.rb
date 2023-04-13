module Admin
  class BooksController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
    # end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # The result of this lookup will be available as `requested_resource`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    # def scoped_resource
    #   if current_user.super_admin?
    #     resource_class
    #   else
    #     resource_class.with_less_stuff
    #   end
    # end

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    # def resource_params
    #   params.require(resource_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes).
    #     transform_values { |value| value == "" ? nil : value }
    # end

    def publish
      requested_resource.title = " published #{Time.zone.now}"
      requested_resource.save
      # redirect_to [namespace, requested_resource]
      redirect_to admin_book_path requested_resource
    end

    def manage_categories
      # call show method to render partial with "page" locals
      # render locals: {
      #   page: Administrate::Page::Show.new(dashboard, requested_resource),
      # }
      show
    end

    def authorized_action?(resource, action)
      return true if resource.instance_of? resource_class # all actions for this resource
      return true if resource.instance_of? Class # all actions ie index for other classes like User

      # For nested resources (like comment) do not allow show and index
      %w[new create edit update destroy].include? action.to_s
    end
  end
end
