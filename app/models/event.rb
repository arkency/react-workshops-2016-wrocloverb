class Event < ActiveRecord::Base
  validates :id, :name, :host, :conference_id, :time_in_minutes, presence: true
  validates :time_in_minutes, numericality: { greater_than: 0, only_integer: true }

  belongs_to :conference, inverse_of: :events

  has_one :planned_event,
          inverse_of: :event,
          autosave: true,
          dependent: :destroy 
end
