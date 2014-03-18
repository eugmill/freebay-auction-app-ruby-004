class SessionsController < ApplicationController

  def new

  end

  def create
    @user = User.find_by(:name => params[:user][:name])
    if @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
      redirect_to auctions_path, :notice => "logged in!"
    else
      render :new
    end
  end

  def destroy 
    reset_session
    redirect_to login_path
  end

end