class PlannedEventSerializer < BaseSerializer
  extend Forwardable
  def_delegators :@url_adapter,
                  :conference_url,
                  :conference_day_url,
                  :conference_day_plan_index_url,
                  :event_url

  def initialize(url_adapter, event_serializer, conference_id, conference_day_id)
    @url_adapter = url_adapter
    @conference_id = conference_id
    @conference_day_id = conference_day_id
    @event_serializer = event_serializer
  end

  def serialize_collection(planned_events)
    { data: [], links: {} }.tap do |root|
      root[:data] = planned_events.map(&method(:serialize_bare))
      root[:links] = {
        self: conference_day_plan_index_url(conference_day_id),
        parent: conference_day_url(conference_day_id)
      }
    end
  end

  private
  attr_reader :conference_day_id, :conference_id, :event_serializer

  def serialize_bare(planned_event)
    {
      id: planned_event.id,
      type: jsonapi_planned_events_type,
      attributes: {
        start: planned_event.start.iso8601(0)
      },
      relationships: {},
      links: {
        parent: conference_day_url(conference_day_id)
      },
      included: []
    }.tap do |root|
      unless planned_event.event.nil?
        event = planned_event.event
        root[:relationships][:event] = { id: event.id, type: jsonapi_events_type }
        root[:included] = [event_serializer.serialize_collection([event])[:data][0]]
        root[:links][:event] = event_url(event.id)
      end
    end
  end

  def jsonapi_planned_events_type
    "planned_events"
  end

  def jsonapi_events_type
    "events"
  end
end