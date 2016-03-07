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

  def expected_event_not_found_error
    json({
      errors: {
        message: "Event not found"
      }
    })
  end

  def expected_event_name_invalid_error
    json({
      errors: {
        message: "Validation failed: Events name can't be blank"
      }
    })
  end

  def expected_conference_not_found_error
    json({
      errors: {
        message: "Conference not found"
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

  def test_showing_invalid_event
    api_client.jsonapi_get(event_url(api_client.next_uuid)) do |response|
      assert_equal expected_event_not_found_error, response
      assert_response :not_found
    end
  end

  def test_index_invalid_conference
    api_client.jsonapi_get(conference_events_url(api_client.next_uuid)) do |response|
      assert_equal expected_conference_not_found_error, response
      assert_response :not_found
    end
  end

  def test_create_invalid_conference
    api_client.jsonapi_post(conference_events_url(api_client.next_uuid),
      event: {
        id: api_client.next_uuid,
        name: "Working with Legacy Code",
        host: "Andrzej Krzywda",
        time_in_minutes: 60
      }) do |response|
      assert_equal expected_conference_not_found_error, response
      assert_response :not_found
    end
  end

  def test_create_without_name
    api_client.assert_post_error_response(events_endpoint,
      { event: {
          id: api_client.next_uuid,
          name: "",
          host: "Andrzej Krzywda",
          time_in_minutes: 60
      }}, expected_event_name_invalid_error)
  end

  def test_destroying_event
    api_client.next_uuid.tap do |event_id|
      api_client.create(events_endpoint,
                        event: {
                            id: event_id,
                            name: "Working with Legacy Code",
                            host: "Andrzej Krzywda",
                            description: "Cool tricks to make your codebase manageable.",
                            time_in_minutes: 60
                        })

      api_client.discover_index_links!(events_endpoint)

      api_client.jsonapi_delete(api_client[:"events:#{event_id}/self"]) do
        assert_response :ok
      end

      api_client.assert_get_response(:"events:#{event_id}/self",
                                     expected_event_not_found_error, :not_found)
    end
  end

  def test_destroying_invalid_event
    api_client.jsonapi_delete(event_url(api_client.next_uuid)) do |response|
      assert_equal expected_event_not_found_error, response
      assert_response :not_found
    end
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