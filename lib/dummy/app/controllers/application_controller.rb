class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def index
    Pet.find_by_name(Pet.pluck(:name).sample).then { _1.update!(name: _1.name + " !") }
  end
end
