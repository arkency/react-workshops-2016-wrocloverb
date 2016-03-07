class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def index
    respond_to do |format|
      format.html { render text: "Hello!" }
      format.jsonapi { render json: root_jsonapi_response }
      format.all { head :bad_request }
    end 
  end

  private
  def root_jsonapi_response
    {
      jsonapi: {
        version: "1.0"
      },
      links: {
        conferences: conferences_url
      }
    }
  end

  def render_error(exc)
    render json: { errors: { message: exc.message } }, status: :unprocessable_entity
  end
end
