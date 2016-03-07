class ConferenceDaysController < ApplicationController
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
          conference = Conference.find(params[:conference_id])
          conference.schedule_day(conference_day_params)
          conference.save!
          head :created
        rescue ConferenceDayTooLong
          render json: { errors: {
                          message: "Validation failed: conference day is too long " +
                                   "(should be within 24 hours)"
                         }
                       },
                 status: :unprocessable_entity
        rescue ConferenceDaysOverlap
          render json: { errors: {
              message: "Validation failed: New day is overlapping an existing day"
            }
          },
          status: :unprocessable_entity
        rescue ConferenceDayInvalidRange
          render json: { errors: {
              message: "Validation failed: New day starts after its end (ensure from-to is valid!)"
            }
          }, status: :unprocessable_entity
        rescue ActiveRecord::RecordNotFound
          render json: {
              errors: {
                  message: "Conference not found"
              }, status: :not_found
          }
        rescue ActiveRecord::RecordInvalid => e
          render_error(e)
        end
      end

      format.all { head :bad_request }
    end
  end

  private
  def conference_day_params
    params.require(:conference_day).permit(:id, :label, :from, :to)
  end

  def index_response_body
    days = ConferenceDay.where(conference_id: params[:conference_id])
    ConferenceDaySerializer.new(self, params[:conference_id]).serialize_collection(days)
  end
end