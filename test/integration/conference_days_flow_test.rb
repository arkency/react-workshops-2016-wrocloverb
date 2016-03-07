require 'test_helper'

module ExpectedConferenceDaysFlowResponses
  def expected_days_index_response(conference_id, id)
    json({
      data: [{
        id: id,
        type: "conference_days",
        attributes: {
          label: "Day 1",
          from: "2016-03-11T10:00:00Z",
          to: "2016-03-11T22:59:00Z",
        },
        relationships: {
          plan: { data: [] }
        },
        links: {
          parent: conference_url(conference_id),
          self: conference_day_url(id),
          plan: conference_day_plan_index_url(id)
        }
      }],
      links: {
        self: conference_days_url(conference_id)
      }
    })
  end

  def expected_show_response(id, conference_id)
    json({
      data: {
        id: id,
        type: "conference_days",
        attributes: {
          label: "Day 1",
          from: "2016-03-11T10:00:00Z",
          to: "2016-03-11T22:00:00Z"
        },
        relationships: {
          plan: { data: [] }
        }
      },
      links: {
        parent: conference_url(conference_id),
        self: conference_day_url(id),
        plan: conference_day_plan_index_url(id)
      }
    })
  end

  def expected_show_response_with_plan(id, conference_id, planned_event_id)
    expected_show_response(id, conference_id).tap do |response|
      response["data"]["relationships"]["plan"]["data"] << { "id" => planned_event_id,
                                                             "type" => "planned_events" }
    end
  end

  def expected_too_long_day_response
    json({
      errors: {
        message: "Validation failed: conference day is too long (should be within 24 hours)"
      }
    })
  end

  def expected_overlapping_days_response
    json({
      errors: {
        message: "Validation failed: New day is overlapping an existing day"
      }
    })
  end

  def expected_label_missing_error
    json({
      errors: {
        message: "Validation failed: Label can't be blank"
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

  def expected_conference_day_not_found_error
    json({
      errors: {
        message: "Conference day not found"
      }
    })
  end

  def expected_invalid_range_response
    json({
      errors: {
        message: "Validation failed: New day starts after its end (ensure from-to is valid!)"
      }
    })
  end
end

class ConferenceDaysFlowTest < ApplicationAPITestSet
  include ExpectedConferenceDaysFlowResponses

  def test_index_responds_conference_days_details
    api_client.next_uuid.tap do |conference_day_id|
      api_client.create(conference_days_endpoint,
        conference_day: {
          id: conference_day_id,
          label: "Day 1",
          from: "2016-03-11T11:00:00+01:00",
          to: "2016-03-11T23:59:00+01:00"
        })

      api_client.assert_get_response(conference_days_endpoint,
        expected_days_index_response(conference_id, conference_day_id))
    end
  end

  def test_too_long_day_error
    api_client.assert_post_error_response(conference_days_endpoint,
      { conference_day: {
        id: api_client.next_uuid,
        label: "Day 1",
        from: "2016-03-11T11:00:00+01:00",
        to: "2016-03-12T11:00:01+01:00"
      }}, expected_too_long_day_response)
  end

  def test_day_overlap_error
    api_client.create(conference_days_endpoint,
      conference_day: {
          id: api_client.next_uuid,
          label: "Day 1",
          from: "2016-03-11T11:00:00+01:00",
          to: "2016-03-11T23:00:00+01:00"
      })

    api_client.assert_post_error_response(conference_days_endpoint,
      { conference_day: {
         id: api_client.next_uuid,
         label: "Day 2",
         from: "2016-03-11T16:00:00+01:00",
         to: "2016-03-11T23:30:00+01:00"
       }}, expected_overlapping_days_response)
  end

  def test_invalid_range_error
    api_client.assert_post_error_response(conference_days_endpoint,
      { conference_day: {
         id: api_client.next_uuid,
         label: "Invalid Day",
         from: "2016-03-11T12:00:00+01:00",
         to: "2016-03-11T10:00:00+01:00"
      }}, expected_invalid_range_response)
  end

  def test_show_response
    api_client.next_uuid.tap do |conference_day_id|
      api_client.create(conference_days_endpoint,
        conference_day: {
          id: conference_day_id,
          label: "Day 1",
          from: "2016-03-11T11:00:00+01:00",
          to: "2016-03-11T23:00:00+01:00"
        })

      api_client.discover_index_links!(conference_days_endpoint)

      api_client.assert_get_response(conference_day_endpoint(conference_day_id),
        expected_show_response(conference_day_id, conference_id))
    end
  end

  def test_show_response_with_planned_event
    api_client.next_uuid.tap do |event_id|
      api_client.next_uuid.tap do |conference_day_id|
        api_client.create(events_endpoint,
          event: {
            id: event_id,
            name: "Working with Legacy Codebase",
            host: "Andrzej Krzywda",
            time_in_minutes: 60
          }
        )

        api_client.create(conference_days_endpoint,
          conference_day: {
            id: conference_day_id,
            from: "2016-03-11T11:00:00+01:00",
            to: "2016-03-11T23:00:00+01:00",
            label: "Day 1"
          })

        api_client.discover_index_links!(conference_days_endpoint)

        api_client.next_uuid.tap do |planned_event_id|
          api_client.create(conference_day_plan_endpoint(conference_day_id),
            planned_event: {
              id: planned_event_id,
              start: "2016-03-11T11:00:00+01:00",
              event_id: event_id
            })

          api_client.assert_get_response(conference_day_endpoint(conference_day_id),
            expected_show_response_with_plan(conference_day_id, conference_id, planned_event_id))
        end
      end
    end
  end

  def test_conference_not_found_index_error
    api_client.jsonapi_get(conference_days_url(api_client.next_uuid)) do |response|
      assert_response :not_found
      assert_equal expected_conference_not_found_error, response
    end
  end

  def test_conference_not_found_create_error
    api_client.jsonapi_post(conference_days_url(api_client.next_uuid),
      conference_day: {
        id: api_client.next_uuid,
        from: "2016-03-11T11:00:00+01:00",
        to: "2016-03-11T13:00:00+01:00",
        label: "Day 1"
      }) do |response|
      assert_response :not_found
      assert_equal expected_conference_not_found_error, response
    end
  end

  def test_conference_day_not_found_show_error
    api_client.jsonapi_get(conference_day_url(api_client.next_uuid)) do |response|
      assert_response :not_found
      assert_equal expected_conference_day_not_found_error, response
    end
  end

  def test_conference_day_validation_error
    api_client.assert_post_error_response(conference_days_endpoint,
      { conference_day: {
          id: api_client.next_uuid,
          label: "",
          from: "2016-03-11T11:00:00+01:00",
          to: "2016-03-11T23:00:00+01:00"
      }}, expected_label_missing_error)
  end

  private
  def api_client
    @api_client ||= TestAPIClient.new(self).tap do |client|
      client.learn_root_urls!
      client.set!(:"conference_id", client.next_uuid)
      client[:"conference_id"].tap do |conference_id|
        client.create(conferences_endpoint,
          conference: {
            id: conference_id,
            name: "wroc_love.rb 2016"
          })
      end

      client.discover_index_links!(conferences_endpoint)
    end
  end

  def conference_id
    api_client[:"conference_id"]
  end

  def conferences_endpoint
    :"root/conferences"
  end

  def conference_day_endpoint(id)
    :"conference_days:#{id}/self"
  end

  def conference_day_plan_endpoint(id)
    :"conference_days:#{id}/plan"
  end

  def conference_days_endpoint
    :"conferences:#{conference_id}/days"
  end

  def events_endpoint
    :"conferences:#{conference_id}/events"
  end
end