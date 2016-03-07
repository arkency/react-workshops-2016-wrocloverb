require 'test_helper'

module EventsFlowExpectedResponses
  def expected_events_index_response(event_id, conference_id)
    json({
      data: [
        {
          id: event_id,
          type: "events",
          attributes: {
            name: "Working with Legacy Code",
            host: "Andrzej Krzywda",
            description: "",
            time_in_minutes: 60
          },
          links: {
            self: event_url(event_id),
            parent: conference_url(conference_id)
          }
        }
      ],
      links: {
        parent: conference_url(conference_id),
        self: conference_events_url(conference_id)
      }
    })
  end

  def expected_event_show_response(event_id, conference_id)
    json({
      data: {
        id: event_id,
        type: "events",
        attributes: {
          name: "Working with Legacy Code",
          host: "Andrzej Krzywda",
          description: "Cool tricks to make your codebase manageable.",
          time_in_minutes: 60
        }
      },
      links: {
        self: event_url(event_id),
        parent: conference_url(conference_id)
      }
    })
  end
end

class EventsFlowTest < ApplicationAPITestSet
  include EventsFlowExpectedResponses

  def test_listing_events
    event_id = api_client.next_uuid

    api_client.create(events_endpoint,
      event: {
        id: event_id,
        name: "Working with Legacy Code",
        host: "Andrzej Krzywda",
        time_in_minutes: 60
      })

    api_client.assert_get_response(events_endpoint,
      expected_events_index_response(event_id, conference_id))
  end

  def test_showing_an_event
    event_id = api_client.next_uuid

    api_client.create(events_endpoint,
      event: {
          id: event_id,
          name: "Working with Legacy Code",
          host: "Andrzej Krzywda",
          description: "Cool tricks to make your codebase manageable.",
          time_in_minutes: 60
      })

    api_client.discover_index_links!(events_endpoint)

    api_client.assert_get_response(:"events:#{event_id}/self",
      expected_event_show_response(event_id, conference_id))
  end

  private
  def api_client
    @api_client ||= TestAPIClient.new(self).tap do |client|
      client.learn_root_urls!
      client.set!(:"conference_id", client.next_uuid)

      client.create(:"root/conferences",
        conference: {
            id: client[:"conference_id"],
            name: "wroc_love.rb 2016"
        })

      client.discover_index_links!(:"root/conferences")
    end
  end

  def conference_id
    api_client[:"conference_id"]
  end

  def events_endpoint
    :"conferences:#{conference_id}/events"
  end
end