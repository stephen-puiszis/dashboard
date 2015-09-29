class Dashing.ChicagoTransitAuthority extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    @set('buses', @transformData(data.train))
    @set('trains', data.train)
    $(@node).fadeOut().fadeIn()


  transformData: (data) ->
    for obj in data
      obj.station = "#{obj.station} - #{obj.direction}"


    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example:  will make the node flash each time data comes in.


