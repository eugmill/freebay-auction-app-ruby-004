class BidsController < ApplicationController
  before_action :require_login, only: [:create]
  def index
    @auction = Auction.find(params[:auction_id])
    @bids = @auction.bids
  end

  def new
    @auction = Auction.find(params[:auction_id])
    @bid = Bid.new
  end

  def show 
    @bid = Bid.find(params[:id])
  end


  def create
    @auction = Auction.find(params[:auction_id])
    @bid = Bid.new(bid_params)
    @bid.auction = @auction
    if @bid.save
      redirect_to @auction, :notice => "Bid successfully placed"
    else
      flash[:error] = @bid.errors.full_messages
      render :new
    end
  end

  private

  def bid_params
    params.require(:bid).permit(:amount)
  end

end
 