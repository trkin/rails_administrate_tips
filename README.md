# Rails Administrate Tips

[Administrate](https://administrate-demo.herokuapp.com/getting_started)
documentation is hosted on Heroku, and [demo app](https://administrate-demo.herokuapp.com/admin) is under
[spec](https://github.com/thoughtbot/administrate/tree/895d5707a5f059847300f3647b3a8a57b3891836/spec/example_app)
folder so you can see how the spec are written


## Install

```
bundle add administrate

rails generate administrate:install
# this will generate app/dashboard/name_dashboard.rb and
# app/controllers/admin/name_controller.rb for each existing ApplicationRecord
```

It depends on Spockets so when you are using Propshaft there is an error
```
rails generate administrate:install
/Users/dule/.rbenv/versions/3.2.0/lib/ruby/gems/3.2.0/gems/sprockets-rails-3.4.2/lib/sprockets/railtie.rb:110:in `block in <class:Railtie>': Expected to find a manifest file in `app/assets/config/manifest.js` (Sprockets::Railtie::ManifestNeededError)
But did not, please create this file and use it to link any assets that need
to be rendered by your app:
```
solution is to revert back to sprockets untill this is merged
<https://github.com/thoughtbot/administrate/issues/2311>
```
# Gemfile
gem "sprockets-rails"
```

## Basic usage

Generate new dashboard pages

```
rails g administrate:dashboard Candidate
```
You can overwrite specific views

```
rails g administrate:views
rails g administrate:views:index # index show edit new # new and edit (also generate _form)
rails g administrate:views:index candidate # only for specific resource
```
or layout
```
rails g administrate:views:layout
rails g administrate:views:navigation # only this partial
```
or field attribute partials
```
rails g administrate:views:field number
rails g administrate:views:field has_many
```
* overwrite display name
  ```
  # app/dashboards/book_dashboard.rb
  def display_resource(book)
    book.name
  end
  ```
* change labels using I18n <https://administrate-demo.herokuapp.com/customizing_dashboards>

## Shallow resources

It does not support nested resources
https://github.com/thoughtbot/administrate/issues/1946
since you need to override paths to include nested resource link.
It is easier with root level resource and pass the parameter book_id
You can also use concern `BookNestedable` (rename with your own model)
```
rails g administrate:views:show books

# app/views/admin/books/show.html.erb
    <%= link_to(
      "Add review",
      [:new, namespace, :review, book_id: page.resource.id],
      class: "button",
    ) if accessible_action?(:review, :new) %>
    # new_admin_review_path(book_id: page.resource),

# app/controllers/admin/reviews_controller.rb
  include BookNestedable

# app/dashboards/review_dashboard.rb
# make sure you add :book to FORM_ATTRIBUTES

# app/controllers/concerns/book_nestedable.rb
module BookNestedable
  extend ActiveSupport::Concern

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
```
Note that if you want to disable show link on small table for HasMany field you
need to overrite authorized_action on that controller

```
# app/controllers/admin/books_controller.rb
    def authorized_action?(resource, action)
      return true if resource.instance_of? Class # all actions ie index for other classes like User
      return true if resource.instance_of? resource_class # all actions for this resource

      # For nested resources (like comment) do not allow show and index
      %w[new create edit update destroy].include? action.to_s
    end
```

To render show on form is not easy since you need to create new page instance
which needs dashabord which uses resolver and it is not available as
helper_method
https://github.com/thoughtbot/administrate/blob/main/app/controllers/administrate/application_controller.rb#L226


## Advance fields

Basic fields you can find on
<https://administrate-demo.herokuapp.com/customizing_dashboards>
You can create new field
<https://administrate-demo.herokuapp.com/adding_custom_field_types>

You can find advanced fields on this places:
* <https://administrate-demo.herokuapp.com/extending_administrate>
* <https://rubygems.org/gems/administrate/reverse_dependencies>
* <https://github.com/thoughtbot/administrate/wiki/List-of-Plugins>

### Multiple select

This can be achieved with simple custom field type
<https://administrate-demo.herokuapp.com/adding_custom_field_types>

<https://stackoverflow.com/a/40701551/287166>
```
rails g administrate:field multiple_select_field

# Create column type array: true
# db/migrate/20230401161816_create_books.rb
class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :categories_array, array: true, default: []

# Add permitted_attribute that accepts array
# app/fiels/multiple_select_field_field.rb
  def self.permitted_attribute(attribute, _options = nil)
    {attribute.to_sym => []}
  end

  def permitted_attribute
    self.class.permitted_attribute(attribute)
  end

# Add multiple:true to _form.html.erb
# app/views/fields/multiple_select_field_field/_form.html.erb
# Original select
# https://github.com/thoughtbot/administrate/blob/main/app/views/fields/select/_form.html.erb
<div class="field-unit__label">
  <%= f.label field.attribute %>
</div>
<div class="field-unit__field">
  <%= f.select(
    field.attribute,
    options_from_collection_for_select(
      field.selectable_options,
      :to_s,
      :to_s,
      field.data.presence,
    ),
    {}, multiple: true,
  ) %>
</div>

# app/dashboards/book_dashboard.rb
class BookDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    categories_array: MultipleSelectFieldField.with_options(
      collection: ["A", "B"]
    ),
```

### Active storage

https://github.com/Dreamersoul/administrate-field-active_storage
so you can attach files and see preview of pdf or image.

```
# bundle add image_processing # this is probably already in Gemfile
bundle add administrate-field-active_storage

# app/models/book.rb
class Book < ApplicationRecord
  has_one_attached :attachment

# app/dashboards/book_dashboard.rb
  ATTRIBUTE_TYPES = {
    attachment: Field::ActiveStorage,
  }
  FORM_ATTRIBUTES = %i[
      attachment
  ]

# app/assets/config/manifest.js
//= link administrate-field-active_storage/application.css
```

### Action text

Plugin <https://github.com/ianwalter/administrate-field-trix> that enable
rich_text_area <https://guides.rubyonrails.org/action_text_overview.html>

```
# install action_text_rich_texts and active_storage tables if you already do not
have, add trix to # package.json
rails action_text:install

# app/models/book.rb
class Book < ApplicationRecord
  has_rich_text :content

# Gemfile
gem "trix-rails", require: "trix"
gem "administrate-field-trix"

# app/dashboards/book_dashboard.rb
  ATTRIBUTE_TYPES = {
    content: Field::Trix
  }.freeze

# app/assets/config/manifest.js
//= link administrate-field-trix/application.css
//= link administrate-field-trix/application.js
```

because of error
```
undefined method `html_safe' for #<ActionText::RichText id: nil, name: "instructions", body: nil, record_type: "Company", record_id: "a6ed6bf1-fe31-5dfe-8ab4-484691fdf219", created_at: nil, updated_at: nil>
```
we need to overwrite show with `field.data.to_s`
```
# app/views/fields/trix/_show.html.erb
# https://github.com/ianwalter/administrate-field-trix/blob/master/app/views/fields/trix/_show.html.erb
<%= sanitize(field.data.to_s, attributes: %w(style)) %>
```

## Paper trail

https://github.com/IrvanFza/administrate-field-paper_trail

## Jsonb

https://github.com/codica2/administrate-field-jsonb

## Nested resources

<https://github.com/nickcharlton/administrate-field-nested_has_many>

Similar to basic
[Field::HasMany](https://administrate-demo.herokuapp.com/customizing_dashboards)
we can use NestedHasMany to create nested resources
<https://github.com/nickcharlton/administrate-field-nested_has_many>
```
# Gemfile
gem "administrate-field-nested_has_many"

# app/assets/config/manifest.js
//= link administrate-field-nested_has_many/application.css
//= link administrate-field-nested_has_many/application.js

# app/dashboards/user_dashboard.rb
class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    books: Field::NestedHasMany,

# app/models/user.rb
class User < ApplicationRecord
  has_many :books
  accepts_nested_attributes_for(
    :books,
    reject_if: :all_blank,
    allow_destroy: true
  )
end
```

## Generate custom field


https://github.com/thoughtbot/administrate/wiki/Field:-RichTextAreaField
```
rails g administrate:field rich_text_area

# replace in app/views/fields/rich_text_area_field/_form.html.erb
# <%= f.text_field field.attribute %>
# with
<%= f.rich_text_area field.attribute %>

# app/dashboards/book_dashboard.rb
class BookDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    content: RichTextAreaField
```

## Custom dashboard

<https://administrate-demo.herokuapp.com/adding_controllers_without_related_model>
Add page without model you need to create a route, dashboard based on Custom
dashboard, a view for that page
```
# config/routes.rb
  namespace :admin do
    resources :stats, only: [:index]
  end

# app/dashboards/stat_dashboard.rb
require "administrate/custom_dashboard"

class StatDashboard < Administrate::CustomDashboard
  resource "Stats" # used by administrate in the views
end

# app/controllers/admin/stats_controller.rb
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
```

## Custom action

<https://administrate-demo.herokuapp.com/customizing_controller_actions>
Hide from sidebar is by disabling index with `except: :index`
To add custom action we need to add path, overwrite view to add the new link and
add method to controller
```
# config/routes.rb
    resources :books do
      member do
        patch :publish
      end
    end

rails generate administrate:views:show books
# app/views/admin/books/show.html.erb
# add link or button with path
[:publish, Administrate::NAMESPACE, resource]
publish_admin_book_path(resource)

# in controller you can redirect to show
# app/controllers/admin/books_controller.rb
    def regenerate
      redirect_to [namespace, requested_resource]
    end
```

To add a new custom page you need to add route, link to view and view (you
should copy default show view)
```
# config/routes.rb
    resources :books do
      member do
        get :manage_categories
      end
    end

# app/views/admin/books/manage_categories.html.erb
# same as show rails g administrate:views:show books
# app/views/admin/books/show.html.erb
<%= link_to "Manage categories", [:manage_categories, namespace, page.resource] %>
```

## Labels

Administrate uses locales in their views
<https://github.com/thoughtbot/administrate/blob/main/config/locales/administrate.en.yml>

```
# app/views/admin/books/show.html.erb
      t("administrate.actions.edit_resource", name: page.page_title),
```
`page_title` is dashboard [display_resource](https://github.com/thoughtbot/administrate/blob/main/lib/administrate/page/show.rb#L13)

TODO:
https://github.com/ApprenticeshipStandardsDotOrg/ApprenticeshipStandardsDotOrg
