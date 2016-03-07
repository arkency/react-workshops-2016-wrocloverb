class ConferenceDaysController < ApplicationController
  def index
    respond_to do |format|
      format.html

      format.jsonapi do
        begin
          render json: index_response_body
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

  def show
    respond_to do |format|
      format.html

      format.jsonapi do
        begin
          render json: show_response_body
        rescue ActiveRecord::RecordNotFound
          render json: {
            errors: {
              message: "Conference day not found"
            }
          }, status: :not_found
        end
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
            }
          }, status: :not_found
        rescue ActiveRecord::RecordInvalid => e
          render_error(e)
        end
      end

      format.all { head :bad_request }
    end
  end

  def destroy
    respond_to do |format|
      format.jsonapi do
        begin
          ConferenceDay.find(params[:id]).destroy!
          head :ok
        rescue ActiveRecord::RecordNotFound
          render json: {
              errors: {
                  message: "Conference day not found"
              }
          }, status: :not_found
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
    days = Conference.preload(conference_days: [:planned_events]).find(params[:conference_id]).days
    ConferenceDaySerializer.new(self, params[:conference_id]).serialize_collection(days)
  end

  def show_response_body
    conference_day = ConferenceDay.preload(:planned_events).find(params[:id])
    ConferenceDaySerializer.new(self, conference_day.conference_id).serialize(conference_day)
  end
end