require_relative '../lib/chicago_transit_data'

SCHEDULER.every '5m', :first_in => 0 do |job|
  data = ChicagoTransitData.new(train: [30279, 30280, 30138, 30137], max: 10).arrival_times
  send_event('chicago_transit_authority', data)
end
