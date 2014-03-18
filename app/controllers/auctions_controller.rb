class AuctionsController < ApplicationController
  before_action :require_login, only: [:create, :update, :destroy]

  def index
    @auctions = Auction.get_active_auctions
  end

  def new 
    @auction = Auction.new
  end

  def create
    @auction = Auction.new(auction_params)
    if @auction.save
      redirect_to @auction 
    else 
      flash[:error] = @auction.errors.full_messages
      render 'new'
    end
  end

  def show 
    @auction = Auction.find(params[:id])
  end

  def edit
    @auction = Auction.find(params[:id])
  end

  def update
    @auction = Auction.find(params[:id])
     if @auction.seller_id == current_user.id
      if @auction.update(auction_params)
        redirect_to @auction
      else 
        flash[:error] = @auction.errors.full_messages
        render :edit   
      end
    else
      flash[:error] = "Please log in as the auction owner to update this auction."
      redirect_to login_path
    end
  end

  def destroy 
    @auction = Auction.find(params[:id])
    if @auction.seller_id == current_user.id
      if @auction.destroy
        redirect_to auctions_path
      else
        render 'edit'
      end
    else
      flash[:error] = "Please log in as the auction owner to delete this auction."
      redirect_to login_path
    end  
  end

  private

  def auction_params
    params.require(:auction).permit(:title, :description, :end_time)
  end


end
