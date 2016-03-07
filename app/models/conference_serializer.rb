class ConferenceSerializer < BaseSerializer
  extend Forwardable
  def_delegators :@url_adapter, :conferences_url,
                                :conference_url,
                                :conference_days_url,
                                :conference_events_url

  def initialize(url_adapter)
    @url_adapter = url_adapter
  end

  def serialize(conference)
    ({ data: {}, links: {} }).tap do |root_structure|
      serialize_conference_bare(conference).tap do |bare_serialization|
        root_structure[:data] = bare_serialization.except(:links)
        root_structure[:links] = bare_serialization[:links]
      end
    end
  end

  def serialize_collection(collection)
    ({ data: [], links: {} }).tap do |root_structure|
      root_structure[:data] = collection.map(&method(:serialize_conference_bare))
      root_structure[:links] = {
        self: conferences_url
      }
    end
  end

  private
  def serialize_conference_bare(conference)
    {
      type: jsonapi_type_of_conference,
      id: conference.id,
      attributes: {
        name: conference.name
      },
      relationships: {
        days: { data: [] },
        events: { data: [] }
      },
      links: {
        self: conference_url(conference),
        days: conference_days_url(conference),
        events: conference_events_url(conference)
      }
    }.tap do |bare_conference|
      bare_conference[:relationships][:days][:data] = serialize_relationship(jsonapi_type_of_conference_day,
                                                                             conference.days)
      bare_conference[:relationships][:events][:data] = serialize_relationship(jsonapi_type_of_event,
                                                                              conference.events)
    end
  end

  def jsonapi_type_of_conference
    "conferences"
  end

  def jsonapi_type_of_event
    "events"
  end

  def jsonapi_type_of_conference_day
    "conference_days"
  end
end