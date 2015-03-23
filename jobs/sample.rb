current_karma = 0

SCHEDULER.every '2s' do
  last_karma     = current_karma
  current_karma     = rand(200000)

  send_event('karma', { current: current_karma, last: last_karma })
  send_event('synergy',   { value: rand(100) })
end
