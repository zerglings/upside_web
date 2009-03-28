class WelcomeController < ApplicationController
  def index
    respond_to do |format|
      format.html
    end
  end
  
  def dashboard
    respond_to do |format|
      format.html
    end
  end
end
