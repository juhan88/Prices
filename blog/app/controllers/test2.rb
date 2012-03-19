
require 'net/http'
require 'net/smtp'
require 'open-uri'
require 'nokogiri'
 class VBCE
  attr_accessor :item, :buyCA, :sellCA, :buyUS, :sellUS, :type
 
  def initialize(item, buyCA, sellCA, buyUS, sellUS, type)
    @item = item
	@buyCA = buyCA
    @sellCA = sellCA
	@buyUS = buyUS
	@sellUS = sellUS
	@type = type
  end
  
  def type
	@type
  end
  
  def item
	@item
  end
  
  def buyCA
    @buyCA
  end
  
  def sellCA
	@sellCA
  end
  
  def buyUS
	@buyUS
  end
  
  def sellUS
	@sellUS
  end
  
 end

class Metals
  def initialize(type)
    @type = type		
  end
  
  def type
	@type
  end
  
  
  def checkType(type)
	if(type.downcase.include? 'silver')
		aType = 'SILVER'	
	elsif(type.downcase.include?'gold')
		aType = 'GOLD'
	elsif(type.downcase.include?'platinum')
		aType = 'PLATINUM'
	end 
	return aType
  end

end
 
response = Net::HTTP.get URI.parse("http://www.vbce.ca/index.cfm?fuseaction=fx_services.Gold&Silver")

doc = Nokogiri::HTML(open('http://www.vbce.ca/index.cfm?fuseaction=fx_services.Gold&Silver'))
VBCESLVPricing = []
VBCEGLDPricing = []
VBCEPLTPricing = []

doc.css('tr#list_row_1').each do |node|	
	puts "++++++"
	n = node.text.split('$')
	item = n[0]	
	buyCA = n[1]
	sellCA = n[2]
	buyUS = n[3]
	sellUS = n[4]
	c = Metals.new(item)
	type = c.checkType(item)
	curr = VBCE.new(item, buyCA, sellCA, buyUS, sellUS, type)
	if(type == 'SILVER')
		VBCESLVPricing.push(curr)
	elsif(type == 'GOLD')
		VBCEGLDPricing.push(curr)
	elsif(type =='PLATINUM')
		VBCEPLTPricing.push(curr)
	end
	
	
end

doc.css('tr.list_row_2').each do |node|
	puts "++++++"
	n = node.text.split('$')
	item = n[0]	
	buyCA = n[1]
	sellCA = n[2]
	buyUS = n[3]
	sellUS = n[4]
	c = Metals.new(item)
	type = c.checkType(item)
	curr = VBCE.new(item, buyCA, sellCA, buyUS, sellUS, type)
	if(type == 'SILVER')
		VBCESLVPricing.push(curr)
	elsif(type == 'GOLD')
		VBCEGLDPricing.push(curr)
	elsif(type =='PLATINUM')
		VBCEPLTPricing.push(curr)
	end
end

puts VBCESLVPricing
puts "++++++"

#puts VBCEGLDPricing


#puts VBCEPLTPricing

message = <<MESSAGE_END
From: sudobucks@gmail.com
To: tamabo88@yahoo.ca
Subject: ALERT: Price Change in Precious Metals

Alert! 
Pricing is up.
VBCESLVPricing[0].item

MESSAGE_END

Net::SMTP.start('') do | smtp | 
		smtp.send_message message, 'sudobucks@gmail.com', 'tamabo88@yahoo.ca'
end

