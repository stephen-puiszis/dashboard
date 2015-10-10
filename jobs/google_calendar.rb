require 'icalendar'

calendars = {
  work: Secrets.google_calendar["work"],
  personal: Secrets.google_calendar["personal"],
  athletics: Secrets.google_calendar["athletics"]
}

SCHEDULER.every '10m', :first_in => 0 do |job|
  calendars.each do |k,v|
    url = URI(v)
    result = Net::HTTP.get(url)
    calendars = Icalendar.parse(result)
    calendar = calendars.first
    events = calendar.events.map do |event|
      {
        start: event.dtstart,
        end: event.dtend,
        summary: event.summary
      }
    end.select { |event| event[:start] > DateTime.now }

    events = events.sort { |a, b| a[:start] <=> b[:start] }[0..3]

    send_event("google_calendar_#{k}", { events: events })
  end
end
