module ApplicationHelper
  def controller?(*controller)
    controller.include?(params[:controller])
  end
end
