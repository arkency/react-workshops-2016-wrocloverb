class PlannedEvent < ActiveRecord::Base
  extend Forwardable
  def_delegators :event, :title, :host, :time_in_minutes, :description

  validates :conference_day_id, :event_id, :start, :id, presence: true
  validates :conference_day_id, uniqueness: { scope: [:event_id] }

  belongs_to :event,
             inverse_of: :planned_event

  belongs_to :conference_day,
             inverse_of: :planned_events

  def time_slice
    (start..finish)
  end

  private
  def finish
    start.advance(minutes: time_in_minutes)
  end
end
