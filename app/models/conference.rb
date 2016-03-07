class Conference < ActiveRecord::Base
  validates :id, :name, presence: true
  validates :name, uniqueness: true

  has_many :conference_days,
           inverse_of: :conference,
           autosave: true,
           dependent: :destroy

  has_many :events,
           inverse_of: :conference,
           autosave: true,
           dependent: :destroy

  def days 
    conference_days
  end

  def schedule_day(day_params)
    ConferenceDay.new(day_params).tap do |day|
      raise ConferenceDaysOverlap.new if day_overlaps?(day)
      days << day
    end
  end

  def accept_event(event_params)
    Event.new(event_params).tap do |event|
      events << event
    end
  end

  private
  def day_overlaps?(given_day)
    days.any? { |day| (day.from..day.to).overlaps?((given_day.from..given_day.to)) }
  end
end
