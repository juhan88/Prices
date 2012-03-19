require 'uri'
require 'net/http'
require 'base64'



metals = [ 'SILVER', 'GOLD', 'PLATINUM']

class Metal
  attr_accessor :type, :bid, :ask, :high, :low, :change, :time
 
  def initialize(type, bid, ask, high, low, change, time)
    @type = type
    @bid = bid
	@ask = ask
	@high = high
	@low = low
	@change = change
	@time = time	 
  end
  
  def bid
	@bid
  end
  
  def type
    @type
  end
  
  def ask
    @ask
  end
  
  def high
    @high
  end
  
  def low
    @low
  end
  
  def change
    @change
  end
  
  def time
    @time
  end
end

metalResults = []
metals.each do |n|
		response = Net::HTTP.get URI.parse("http://charts.kitco.com/KitcoCharts/RequestHandler?requestName=getSymbolSnapshot&Symbol=#{n}")
		update = Base64.decode64(response)
		#puts "#{n}: #{prices}"
		results = update.split(' ')
		date = results[0]
		result = results[1].split(',')
		time = result[0]
		bid = result[1]
		ask = result[2]
		change = result[3]
		low = result[4]
		high = result[5]	
		
		curr = Metal.new(n, bid, ask, high, low, change, time)  		
		metalResults.push(curr)
		
end
metalResults.each do |x| 
		
		
		puts x.type
		puts "Real Time: #{x.time}"
		puts "Bid: #{x.bid}"
		puts "Ask: #{x.ask}"
		puts "High: #{x.high}"
		puts "Low: #{x.low}"
		puts "Change: #{x.change}"
end

