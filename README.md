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
Solution is to revert back to sprockets untill this is merged
https://github.com/thoughtbot/administrate/issues/2311
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
or you can create new field
https://administrate-demo.herokuapp.com/adding_custom_field_types

* overwrite display name
  ```
  # app/dashboards/book_dashboard.rb
  def display_resource(book)
    book.name
  end
  ```
* change labels using I18n https://administrate-demo.herokuapp.com/customizing_dashboards

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
