class WelcomeController < ApplicationController
  def index
    @config = {
      label: 'Users',
      default_sort_by: 'first_name',
      crud_path: 'users',
    }
  end
end
