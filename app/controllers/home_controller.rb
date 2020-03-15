class HomeController < ApplicationController
  skip_before_action :authorized

  def show
  end
end
