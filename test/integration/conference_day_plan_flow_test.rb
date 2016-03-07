require 'test_helper'

module ConferenceDayPlanExpectedResponses
  def expected_empty_plan_response(day_id)
    json({
      data: [],
      links: {
        self: conference_day_plan_index_url(day_id),
        parent: conference_day_url(day_id)
      }
    })
  end

  def expected_plan_with_first_planned_event_response(conference_id,
                                                      day_id,
                                                      event_id,
                                                      planned_event_id)
    json({
      data: [
        {
          id: planned_event_id,
          type: "planned_events",
          attributes: {
            start: "2016-03-11T12:00:00Z"
          },
          relationships: {
            event: { id: event_id, type: "events" }
          },
          links: {
            event: event_url(event_id),
            parent: conference_day_url(day_id)
          },
          included: [
            {
              id: event_id,
              type: "events",
              attributes: {
                name: "Working with Legacy Code",
                host: "Andrzej Krzywda",
                description: "Cool tricks to make your code manageable",
                time_in_minutes: 60
              },
              links: {
                self: event_url(event_id),
                parent: conference_url(conference_id)
              }
            }
          ]
         }
       ],
       links: {
         self: conference_day_plan_index_url(day_id),
         parent: conference_day_url(day_id)
       }
    })
  end

  def expected_not_within_day_error
    json({
      errors: {
        message: "Validation failed: Planned event not within day boundaries"
      }
    })
  end

  def expected_overlapping_events_error
    json({
      errors: {
        message: "Validation failed: Event schedule overlaps with previously planned events"
      }
    })
  end

  def expected_event_planned_twice_error
    json({
      errors: {
        message: "Validation failed: Event is already planned"
      }
    })
  end
end

class ConferenceDayPlanFlowTest < ApplicationAPITestSet
  include ConferenceDayPlanExpectedResponses

  def test_hitting_plan_link_returns_empty_planned_events_at_first
    api_client.assert_get_response(:"conference_days:#{conference_day_id}/plan",
                               expected_empty_plan_response(conference_day_id))
  end

  def test_creating_planned_event_reflects_index_response
    api_client.next_uuid.tap do |planned_event_id|
      api_client.create(plan_endpoint,
        planned_event: {
          id: planned_event_id,
          start: "2016-03-11T13:00:00+01:00",
          event_id: event_id
        })

      api_client.assert_get_response(plan_endpoint,
        expected_plan_with_first_planned_event_response(conference_id,
                                                        conference_day_id,
                                                        event_id,
                                                        planned_event_id))
    end
  end

  def test_event_not_within_day_error
    api_client.assert_post_error_response(plan_endpoint,
                                          { planned_event: {
                                              id: api_client.next_uuid,
                                              start: "2015-11-20T18:30:00+01:00",
                                              event_id: event_id
                                          }}, expected_not_within_day_error)
  end

  def test_overlapping_events_error
    api_client.next_uuid.tap do |correct_event_id|
      api_client.create(events_endpoint,
        event: {
          id: correct_event_id,
          name: "React.js Workshops",
          host: "Marcin Grzywaczewski",
          time_in_minutes: 60
        })

      api_client.create(plan_endpoint,
        planned_event: {
          id: api_client.next_uuid,
          start: "2016-03-11T12:00:00+01:00",
          event_id: correct_event_id
        })

      api_client.assert_post_error_response(plan_endpoint,
        { planned_event: {
          id: api_client.next_uuid,
          start: "2016-03-11T12:30:00+01:00",
          event_id: event_id
        }}, expected_overlapping_events_error)
    end
  end

  def test_event_planned_twice_error
    api_client.create(plan_endpoint,
      planned_event: {
        id: api_client.next_uuid,
        start: "2016-03-11T12:00:00+01:00",
        event_id: event_id
      })

    api_client.assert_post_error_response(plan_endpoint,
      { planned_event: {
        id: api_client.next_uuid,
        start: "2016-03-11T14:00:00+01:00",
        event_id: event_id
      }}, expected_event_planned_twice_error)
  end

  private
  def api_client
    @api_client ||= TestAPIClient.new(self).tap do |client|
      client.learn_root_urls!
      client.set!(:"conference_id", client.next_uuid)
      client.set!(:"conference_day_id", client.next_uuid)
      client.set!(:"event_id", client.next_uuid)
      conference_id = client[:"conference_id"]
      conference_day_id = client[:"conference_day_id"]
      event_id = client[:"event_id"]

      client.create(:"root/conferences",
        conference: {
            id: conference_id,
            name: "wroc_love.rb 2016"
        })

      client.discover_index_links!(:"root/conferences")

      client.create(:"conferences:#{conference_id}/days",
        conference_day: {
            id: conference_day_id,
            label: "Day 1",
            from: "2016-03-11T11:00:00+01:00",
            to: "2016-03-11T23:00:00+01:00"
        })

      client.create(:"conferences:#{conference_id}/events",
         event: {
             id: event_id,
             name: "Working with Legacy Code",
             host: "Andrzej Krzywda",
             description: "Cool tricks to make your code manageable",
             time_in_minutes: 60
         })

      client.discover_show_links!(:"conferences:#{conference_id}/self")
      client.discover_index_links!(:"conferences:#{conference_id}/days")
    end
  end

  def conference_id
    api_client[:"conference_id"]
  end

  def conference_day_id
    api_client[:"conference_day_id"]
  end

  def event_id
    api_client[:"event_id"]
  end

  def plan_endpoint
    :"conference_days:#{conference_day_id}/plan"
  end

  def events_endpoint
    :"conferences:#{conference_id}/events"
  end
end