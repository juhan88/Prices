class UserMailer < ActionMailer::Base
  default from: "notifications@spotprice.ca"
  
  def welcome_email(user)
	@user = user
	@url  = "http://spotprice.ca/login"
	mail(:to => user.email, :subject => "Welcome to SpotPrice.ca")
	
  end
end
