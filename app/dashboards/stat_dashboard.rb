require "administrate/custom_dashboard"

class StatDashboard < Administrate::CustomDashboard
  resource "Stats" # used by administrate in the views
end
