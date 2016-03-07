class EventSerializer < BaseSerializer
  extend Forwardable
  def_delegators :@url_adapter,
                 :conference_url,
                 :event_url,
                 :conference_events_url

  def initialize(url_adapter, conference_id)
    @url_adapter = url_adapter
    @conference_id = conference_id
  end

  def serialize(event)
    { data: {}, links: {} }.tap do |root|
      bare_event = serialize_bare(event)

      root[:data] = bare_event.except(:links)
      root[:links] = bare_event[:links]
    end
  end

  def serialize_collection(events)
    { data: [], links: {} }.tap do |root|
      root[:data] = events.map(&method(:serialize_bare))
      root[:links] = {
        self: conference_events_url(conference_id),
        parent: conference_url(conference_id)
      }
    end
  end

  private
  attr_reader :conference_id

  def serialize_bare(event)
    {
      id: event.id,
      type: jsonapi_event_type,
      attributes: {
        name: event.name,
        host: event.host,
        description: event.description,
        time_in_minutes: event.time_in_minutes
      },
      links: {
        self: event_url(event),
        parent: conference_url(conference_id)
      }
    }
  end

  def jsonapi_event_type
    "events"
  end
end