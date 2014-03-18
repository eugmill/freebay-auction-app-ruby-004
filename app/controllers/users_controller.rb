class UsersController < ApplicationController


  def new 
    @user = User.new
  end

  def create 
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "Successfully signed up!"
      redirect_to auctions_path 
    else 
      flash.now[:error] = @user.errors.full_messages

      render :new
    end
  end

  def show 
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
 