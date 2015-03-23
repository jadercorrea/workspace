require 'mechanize'

points = []
(1..10).each do |i|
  points << { x: i, y: 0 }
end
last_index = points.last[:x]

SCHEDULER.every '10s' do
  points.shift
  last_index += 1

  mechanize = Mechanize.new
  mechanize.get('http://dolarhoje.com') do |page|
    currency = page.search('input#nacional').first[:value].gsub(',', '.')
    points << { x: last_index, y: currency.to_f }
  end

  send_event('convergence', points: points)
  send_event('valuation', { current: points.last[:y], last: points.first[:y] })
end
