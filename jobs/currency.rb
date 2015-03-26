require 'mechanize'

def matrix
  points = []
  (1..10).each do |i|
    points << { x: i, y: 0 }
  end
  points
end

def search(page, element)
  page.search(element).first[:value].gsub(',', '.')
end

def fetch_currency(points)
  points.shift
  last_index  = points.last[:x] + 1

  mechanize = Mechanize.new
  mechanize.get('http://dolarhoje.com') do |page|
    currency = search(page, 'input#nacional')
    points << { x: last_index, y: currency.to_f }
  end
  points
end

SCHEDULER.every '10s' do
  points = points || matrix
  send_event('convergence', points: fetch_currency(points))
end
