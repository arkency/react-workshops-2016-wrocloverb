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
          plan: { data: {} }
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

  def conference_days_endpoint
    :"conferences:#{conference_id}/days"
  end
end