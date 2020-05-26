class PagesController < ApplicationController
  skip_before_action :authorized

  def index
  end

  def privacy
  end

  def transparency
  end
end
