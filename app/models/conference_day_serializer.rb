class ConferenceDaySerializer < BaseSerializer
  extend Forwardable
  def_delegators :@url_adapter,
                 :conference_url,
                 :conference_day_url,
                 :conference_day_plan_index_url,
                 :conference_days_url

  def initialize(url_adapter, conference_id)
    @url_adapter = url_adapter
    @conference_id = conference_id
  end

  def serialize_collection(collection)
    ({ data: [], links: {} }).tap do |root_structure|
      root_structure[:data] = collection.map(&method(:serialize_conference_day_bare))
      root_structure[:links] = {
        self: conference_days_url(conference_id)
      }
    end
  end

  private
  attr_reader :conference_id

  def serialize_conference_day_bare(conference_day)
    {
        type: jsonapi_type_of_conference_day,
        id: conference_day.id,
        attributes: {
            label: conference_day.label,
            from: conference_day.from.iso8601(0),
            to: conference_day.to.iso8601(0)
        },
        relationships: { plan: { data: {} } },
        links: {
            self: conference_day_url(conference_day),
            plan: conference_day_plan_index_url(conference_day.id),
            parent: conference_url(conference_id)
        }
    }
  end

  def jsonapi_type_of_conference_day
    "conference_days"
  end

  def jsonapi_type_of_conference_day_plan
    "conference_day_plan"
  end
end