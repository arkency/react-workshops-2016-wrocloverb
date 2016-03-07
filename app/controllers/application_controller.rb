class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  protected
  def render_error(exc)
    render json: { errors: { message: exc.message } }, status: :unprocessable_entity
  end
end
