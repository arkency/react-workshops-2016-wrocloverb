require 'test_helper'

module ExpectedConferenceFlowResponses
  def expected_first_index_response
    json({
      data: [],
      links: { self: conferences_url }
    })
  end

  def expected_show_conference_with_events_response(id, event_id)
    expected_show_conference_response(id).tap do |root|
      root["data"]["relationships"]["events"]["data"] << { "id" => event_id, "type" => "events" }
    end
  end

  def expected_show_conference_with_days_response(id, day_id)
    expected_show_conference_response(id).tap do |root|
      root["data"]["relationships"]["days"]["data"] << { "id" => day_id, "type" => "conference_days" }
    end
  end

  def expected_created_conference_response(id)
    json({
      data: [
        { id: id,
          type: "conferences",
          attributes: {
            name: "wroc_love.rb 2016"
          },
          relationships: {
            days: { data: [] },
            events: { data: [] }
          },
          links: {
            self: conference_url(id),
            days: conference_days_url(id),
            events: conference_events_url(id)
          }
        }
      ],
      links: { self: conferences_url }
    })
  end

  def expected_show_conference_response(id)
    json({
      data: {
        id: id,
        type: "conferences",
        attributes: {
          name: "wroc_love.rb 2016"
        },
        relationships: {
          days: { data: [] },
          events: { data: [] }
        }
      },
      links: {
        self: conference_url(id),
        days: conference_days_url(id),
        events: conference_events_url(id)
      }
    })
  end

  def expected_conference_uniqueness_error
    json({ errors: {
      message: "Validation failed: Name has already been taken"
    }})
  end
end

class ConferencesFlowTest < ApplicationAPITestSet
  include ExpectedConferenceFlowResponses

  def test_root_endpoint_available_through_html_and_jsonapi
    assert_get_formats(api_client[:"root/conferences"])
  end

  def test_first_call_empty_list_of_conferences
    api_client.assert_get_response(conferences_endpoint,
      expected_first_index_response)
  end

  def test_creation_of_conference_is_visible_on_index
    api_client.next_uuid.tap do |conference_id|
      api_client.create(conferences_endpoint,
        conference: {
          id: conference_id,
          name: "wroc_love.rb 2016"
        })

      api_client.assert_get_response(conferences_endpoint,
        expected_created_conference_response(conference_id))
    end
  end

  def test_single_conference_can_be_fetched
    api_client.next_uuid.tap do |conference_id|
      api_client.create(conferences_endpoint,
                        conference: {
                            id: conference_id,
                            name: "wroc_love.rb 2016"
                        })

      api_client.discover_index_links!(conferences_endpoint)

      :"conferences:#{conference_id}/self".tap do |conference_endpoint|
        api_client.assert_get_response(conference_endpoint,
          expected_show_conference_response(conference_id))
      end
    end
  end

  def test_can_create_and_see_conference_days
    api_client.next_uuid.tap do |conference_id|
      api_client.create(
          conferences_endpoint,
          conference: {
              id: conference_id,
              name: "wroc_love.rb 2016"
          })

      api_client.discover_index_links!(conferences_endpoint)
      api_client.next_uuid.tap do |conference_day_id|
      api_client.create(:"conferences:#{conference_id}/days",
        conference_day: {
          id: conference_day_id,
          label: "Day One",
          from: "2016-03-11T11:00:00+01:00",
          to: "2016-03-11T23:59:00+01:00"
        })

        api_client.assert_get_response(:"conferences:#{conference_id}/self",
          expected_show_conference_with_days_response(conference_id, conference_day_id))
      end
    end
  end

  def test_conference_uniqueness
    api_client.next_uuid.tap do |first_conference_id|
      api_client.next_uuid.tap do |second_conference_id|
        api_client.create(conferences_endpoint,
          conference: {
            id: first_conference_id,
            name: "wroc_love.rb 2016"
          })

        api_client.assert_post_error_response(conferences_endpoint,
          { conference: {
            id: second_conference_id,
            name: "wroc_love.rb 2016"
          }}, expected_conference_uniqueness_error)
      end
    end
  end

  def test_conference_events_visible_after_creation
    api_client.next_uuid.tap do |conference_id|
      api_client.create(conferences_endpoint,
        conference: {
          id: conference_id,
          name: "wroc_love.rb 2016"
        })

      api_client.discover_index_links!(conferences_endpoint)

      :"conferences:#{conference_id}/events".tap do |events_endpoint|
        api_client.next_uuid.tap do |event_id|
          api_client.create(events_endpoint,
            event: {
              id: event_id,
              name: "Working with Legacy Code",
              host: "Andrzej Krzywda",
              description: "Cool tricks to make wonders with legacy codebase",
              time_in_minutes: 60
            })

          api_client.assert_get_response(:"conferences:#{conference_id}/self",
            expected_show_conference_with_events_response(conference_id, event_id))
        end
      end
    end
  end

  private
  def api_client
    @api_client ||= TestAPIClient.new(self).tap do |client|
      client.learn_root_urls!
    end
  end

  def conferences_endpoint
    :"root/conferences"
  end
end

