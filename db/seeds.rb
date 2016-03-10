first_conference = Conference.create!(id: SecureRandom.uuid, name: "wroc_love.rb 2016")
second_conference = Conference.create!(id: SecureRandom.uuid, name: "wroc_love.rb 2015")

first_conference.tap do |conference|
  conference.accept_event(id: SecureRandom.uuid,
                          name: "Working with Legacy Code",
                          host: "Andrzej Krzywda",
                          description: "I'll show cool tricks to make your legacy codebase maintainable and make it easy to add new features without introducing regressions.",
                          time_in_minutes: 60)

  conference.accept_event(id: SecureRandom.uuid,
                          name: "React.js + Redux Workshops",
                          host: "Marcin Grzywaczewski",
                          description: "",
                          time_in_minutes: 310)

  conference.schedule_day(id: SecureRandom.uuid,
                          label: "Day 1",
                          from: "2016-03-11T11:00:00+01:00",
                          to: "2016-03-11T23:00:00+01:00")

  conference.schedule_day(id: SecureRandom.uuid,
                          label: "Day 2",
                          from: "2016-03-12T11:00:00+01:00",
                          to: "2016-03-12T23:00:00+01:00")

  conference.schedule_day(id: SecureRandom.uuid,
                          label: "Day 3",
                          from: "2016-03-13T11:00:00+01:00",
                          to: "2016-03-13T23:00:00+01:00")

  conference.days[0].plan_event(id: SecureRandom.uuid,
                                event_id: conference.events[0].id,
                                start: "2016-03-11T13:00:00+01:00")
end

