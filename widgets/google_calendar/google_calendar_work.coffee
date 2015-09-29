class Dashing.GoogleCalendar extends Dashing.Widget

  onData: (data) =>
    event = rest = null
    getEvents = (first, others...) ->
      event = first
      rest = others

    getEvents data.events...

    start = moment(event.start)
    end = moment(event.end)
    @set('event', event)
    @set('event_date', start.format('dddd, MMMM Do'))
    @set('event_times', start.format('HH:mm a') + " - " + end.format('HH:mm a'))

    next_events = []
    for next_event in rest
      time = moment(next_event.start).fromNow();

      next_events.push { summary: next_event.summary, start_time: time }
    @set('next_events', next_events)
