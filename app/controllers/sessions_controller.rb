class SessionsController < ApplicationController

  def new

  end

  def create
    @user = User.find_by(:name => params[:user][:name])
    if @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
      redirect_to auctions_path, :notice => "Successfully logged in!"
    else
      flash[:error] = "Name and password don't match."
      render :new
    end
  end

  def destroy 
    reset_session
    redirect_to auctions_path
  end

end