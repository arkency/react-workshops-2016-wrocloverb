class RootController < ApplicationController
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
end