class EventsController < ApplicationController
  def create
    respond_to do |format|
      format.html
      format.jsonapi do
        begin
          Conference.find(params[:conference_id]).tap do |conference|
            conference.accept_event(create_event_params)
            conference.save!
            head :created
          end
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

  def index
    respond_to do |format|
      format.html
      format.jsonapi do
        begin
          render json: serialized_conference_events
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
      format.jsonapi do
        begin
          Event.find(params[:id]).tap do |event|
            render json: EventSerializer.new(self, event.conference_id).serialize(event)
          end
        rescue ActiveRecord::RecordNotFound
          render json: {
            errors: {
              message: "Event not found"
            }
          }, status: :not_found
        end
      end

      format.all { head :bad_request }
    end
  end

  def destroy
    respond_to do |format|
      format.jsonapi do
        begin
          Event.find(params[:id]).destroy!
          head :ok
        rescue ActiveRecord::RecordNotFound
          render json: {
            errors: {
              message: "Event not found"
            }
          }, status: :not_found
        end
      end

      format.all { head :bad_request }
    end
  end

  private
  def create_event_params
    params.require(:event).permit(:id, :name, :host, :description, :time_in_minutes)
  end

  def conference
    @conference ||= Conference.preload(:events).find(params[:conference_id])
  end

  def serialized_conference_events
    EventSerializer.new(self, conference.id).serialize_collection(conference.events)
  end
end
