class ConferencesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.jsonapi do
        render json: index_response_body
      end
      format.all { head :bad_request }
    end
  end

  def create
    respond_to do |format|
      format.jsonapi do
        begin
          Conference.create!(conference_params)
          head :created
        rescue ActiveRecord::RecordInvalid => e
          render_error(e)
        end
      end

      format.all { head :bad_request }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.jsonapi do
        begin
          render json: show_response_body
        rescue ActiveRecord::RecordNotFound
          render json: {
            errors: {
              message: "Conference not found"
            }
          }, status: :not_found
        end
      end
      format.all { head :bad_request }
    end
  end

  def destroy
  end

  private
  def conference_params
    params.require(:conference).permit(:id, :name)
  end

  def index_response_body
    ConferenceSerializer.new(self).serialize_collection(Conference.preload(:conference_days).all)
  end

  def show_response_body
    ConferenceSerializer.new(self).serialize(Conference.preload(:conference_days).find(params[:id]))
  end
end
