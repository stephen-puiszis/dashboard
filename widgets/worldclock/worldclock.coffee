# Requires moment, moment-timezone and moment-timezone-data be added to the
# assets. And in the html view:
#
# data-title: Display name for location
# data-timezone: string designation for timezone (http://momentjs.com/timezone/data/)
# data-view: Worldclock
# data-id: whatever
class Dashing.Worldclock extends Dashing.Widget
  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = moment(new Date()).zone("-05:00")
    @set('time', today.format('h:mm a'))
    @set('date', today.format("MMM Do"))
