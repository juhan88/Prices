require 'net/http'
require 'open-uri'
require 'nokogiri'

class Colonial
  attr_accessor :item, :buyCA, :type
 
  def initialize(item, buyCA, type)
    @item = item
	@buyCA = buyCA
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
  
 end


ColonialSLVPricing = []

silverDoc = Nokogiri::HTML(open('http://colonialacres.com/products.php?cat=445&order=asc_name&perpage=20&page=0&q='))
product = []
prices = []
inStock = []
#gets the name of product
silverDoc.css('td#productListingTableHeader').each do |n|
	product.push(n.text)
end

silverDoc.css('td#productListingContent').each do |n|
	p = n.text.split('$')
    prices.push(p[1])
end

(0..(product.length-1)).each do |i|
  prod = product[i]
  price = prices[i]
  #doesn't include box, or special edition  
  if(prod != nil && (!prod.downcase.include? 'special edition') && (!prod.downcase.include? 'scrap') && (!prod.downcase.include? 'box'))
	item = prod.split('(')
	currItem = item[0]
	p = price.split('.')		
	p1 = p[0]
	p2 = p[1].split('')
	if(p[0] == '0')
		currPrice = 'out of stock'
	else 
		currPrice = p1 + '.' + p2[0] + p2[1]
	end	
	curr = Colonial.new(currItem, currPrice,'SILVER')
	ColonialSLVPricing.push(curr)  
  end
  
  
end





