class ConferenceDay < ActiveRecord::Base
  belongs_to :conference, inverse_of: :conference_days
  has_many :planned_events,
           autosave: true,
           inverse_of: :conference_day,
           dependent: :destroy

  validates :id, :label, :from, :to, presence: true

  def initialize(*args)
    super(*args)
    validate!
    raise ConferenceDayTooLong.new if hour_span > 24
    raise ConferenceDayInvalidRange.new unless from_to_in_correct_order?
  end

  def plan_event(planned_event_params)
    raise EventPlannedTwice.new unless event_planned_first_time?(planned_event_params[:event_id])
    PlannedEvent.new(planned_event_params).tap do |new_event|
      raise PlannedEventNotWithinDay.new unless planned_event_within_day?(new_event)
      raise PlannedEventsOverlap.new if event_overlapping_with_current_plan?(new_event)
      planned_events << new_event
    end
  end

  private
  def event_overlapping_with_current_plan?(new_event)
    planned_events.map(&:time_slice).any? { |p| p.overlaps?(new_event.time_slice) }
  end

  def planned_event_within_day?(event)
    time_slice.cover?(event.time_slice.begin) && time_slice.cover?(event.time_slice.end)
  end

  def event_planned_first_time?(event_id)
    event = Event.preload(:planned_event).find(event_id)
    event.planned_event.nil?
  end

  def time_slice
    (from..to)
  end

  def from_to_in_correct_order?
    to > from
  end

  def hour_span
    (to - from) / 1.hour
  end
end
