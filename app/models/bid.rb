class Bid < ActiveRecord::Base
  belongs_to :bidder, :class_name => "User"
  belongs_to :auction

  before_save :convert_bid_to_cents

  validate :higher_than_current?
  validates :amount, :numericality => true

  def convert_bid_to_cents
    self.amount = (self.amount*100).to_i
  end

  def amount_in_dollars
    self.amount/100.0
  end 

  def amount_in_cents
    self.amount*100
  end

  def higher_than_current?
    if !Bid.where("amount > ? AND auction_id = ?", amount_in_cents, self.auction.id).empty?
      errors.add(:amount, "is too low! It can't be lower than the current bid, sorry.")
    end  
  end
end
