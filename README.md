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
rails g administrate:views:index # index show edit  new
rails g administrate:views:index Candidate # only for specific resource
```
or layout
```
rails g administrate:views:layout
rails g administrate:views:navigation # only this partial
```
or field attribute partials
```
rails generate administrate:views:field number
```
* overwrite display name
  ```
  # app/dashboards/book_dashboard.rb
  def display_resource(book)
    book.name
  end
  ```
* change labels using I18n <https://administrate-demo.herokuapp.com/customizing_dashboards>

## Advance fields

Basic fields you can find on
<https://administrate-demo.herokuapp.com/customizing_dashboards>
You can create new field
<https://administrate-demo.herokuapp.com/adding_custom_field_types>

You can find advanced fields <https://administrate-demo.herokuapp.com/extending_administrate>
<https://rubygems.org/gems/administrate/reverse_dependencies>
<https://github.com/thoughtbot/administrate/wiki/List-of-Plugins>

### Multiple select

This can be achieved with simple custom field type
<https://administrate-demo.herokuapp.com/adding_custom_field_types>

```
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
 //= link 'administrate-field-active_storage/application.css'
```

### Active text

https://github.com/ianwalter/administrate-field-trix
```
# app/models/book.rb
class Book < ApplicationRecord
  has_rich_text :content

# Gemfile
gem 'trix-rails', require: 'trix'
gem 'administrate-field-trix'

# app/dashboards/book_dashboard.rb
  ATTRIBUTE_TYPES = {
    content: Field::Trix
  }.freeze

# app/assets/config/manifest.js
//= link administrate-field-trix/application.css
//= link administrate-field-trix/application.js
```

also you need to overwrite show with `field.data`
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

Similar to basic [Field::HasMany](https://administrate-demo.herokuapp.com/customizing_dashboards) we can use NestedHasMany to create nested resources
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

## Adding custom action

```
# config/routes.rb
  namespace :admin do
    resources :candidates do
      member do
        patch :mark_as_registered
      end
    end
  end
```

In views you can use `[:mark_as_registered, Administrate::NAMESPACE, resource]`
path or `mark_as_registered_admin_candidate_path`.

TODO:
https://github.com/ApprenticeshipStandardsDotOrg/ApprenticeshipStandardsDotOrg
