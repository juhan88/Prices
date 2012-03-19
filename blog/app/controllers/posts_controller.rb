
class PostsController < ApplicationController
  # GET /posts
  # GET /posts.json
  require 'rubygems'
  require 'bundler/setup'
  require 'nokogiri'
  require 'net/http'
  require 'uri'
  require 'open-uri'
  require 'net/smtp'

  
  
  
  def index
    
	#kitco
	notify = false
	metals = [ 'SILVER', 'GOLD', 'PLATINUM']
	@metalResults = []
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
		if(change.include? '-')
			rate = change.split('-')
			if(rate[1].to_i < 0)
				notify = true
			end
		elsif(change.include? '+')
			rate = change.split('+')
			if(Integer(rate[1]) > 0)
				notify = true
			end
		end
		
		low = result[4]
		high = result[5]
		curr = Metal.new(n, date, bid, ask, high, low, change, time)  		
		@metalResults.push(curr)
   end
   
   if notify	
	 mail(:to => 'tamabo88@yahoo.ca',
		  :subject => "ALERT! Pricing Changed.") 
	 println "+++++++++++++++++++++"
   end
   
   #vbce
    response = Net::HTTP.get URI.parse("http://www.vbce.ca/index.cfm?fuseaction=fx_services.Gold&Silver")

	doc = Nokogiri::HTML(open('http://www.vbce.ca/index.cfm?fuseaction=fx_services.Gold&Silver'))
	@VBCESLVPricing = []
	@VBCEGLDPricing = []
	@VBCEPLTPricing = []

	doc.css('tr.list_row_1').each do |node|	
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
			@VBCESLVPricing.push(curr)
		elsif(type == 'GOLD')
			@VBCEGLDPricing.push(curr)
		elsif(type =='PLATINUM')
			@VBCEPLTPricing.push(curr)
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
			@VBCESLVPricing.push(curr)
		elsif(type == 'GOLD')
			@VBCEGLDPricing.push(curr)
		elsif(type =='PLATINUM')
			@VBCEPLTPricing.push(curr)
		end
	end
   
	#colonial acres
	@ColonialSLVPricing = []

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
	    @ColonialSLVPricing.push(curr) 	
	  end
	end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  def time
   render_text "The current time is #{Time.now.to_s}"
  end
  
  def updatePrices
	metals = [ 'SILVER', 'GOLD', 'PLATINUM']
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
		curr = Metal.new(n, date, bid, ask, high, low, change, time)  		
		@metalResults.push(curr)			
   end
  end

  class Metal
  attr_accessor :type, :date, :bid, :ask, :high, :low, :change, :time
 
  def initialize(type, date, bid, ask, high, low, change, time)
    @type = type
	@date = date
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
  
  def date
	@date
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
  
  # GET /posts/1
  # GET /posts/1.json
  def show
	
    #####end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
     render :text => "The current time is #{Time.now.to_s}"
	 #@post = Post.new

    #respond_to do |format|
    #  format.html # new.html.erb
    #  format.json { render json: @post }
    #end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :ok }
    end
  end
end
