class ApplicationController < ActionController::Base
  protected
  def render_error(exc)
    render json: { errors: { message: exc.message } }, status: :unprocessable_entity
  end
end
