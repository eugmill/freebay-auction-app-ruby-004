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
    @auction.seller = current_user
    if @auction.save
      redirect_to @auction 
    else 
      flash[:error] = @auction.errors.full_messages
      render 'new'
    end
  end

  def show 
    @auction = Auction.find(params[:id])
    @current_bidder = @auction.highest_bidder
  end

  def edit
    @auction = Auction.find(params[:id])
    if @auction.seller_id != current_user.id
      flash[:error] = "Please Log In As The Auction Owner To Update This Auction."
      redirect_to login_path
    else
      flash[:notice] = "Auction has ended, sorry!" if @auction.closed?
      render :edit
    end
  end

  def update
    @auction = Auction.find(params[:id])
     if @auction.seller_id == current_user.id
      if @auction.update(auction_params)
        flash[:notice] = "Auction successfully updated"
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
        redirect_to auctions_path, notice: "Successfully deleted auction. Sorry we're not sorry."
      else
        render 'edit'
      end
    else
      flash[:error] = "Please log in as the auction owner to delete this auction."
      redirect_to login_path
    end  
  end

  def end_auction
    @auction = Auction.find(params[:id])
    @auction.end_time = Time.now
    @auction.force_submit = true
    @auction.save
    flash[:notice] = "Successfully ended auction early."
    redirect_to auctions_path
  end

  private

  def auction_params
    params.require(:auction).permit(:title, :description, :end_time, :picture)
  end


end
