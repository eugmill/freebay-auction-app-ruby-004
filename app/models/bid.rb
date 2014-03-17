class Bid < ActiveRecord::Base
  belongs_to :bidder, :class_name => "User"
  belongs_to :auction

  before_save :convert_bid_to_cents

  def convert_bid_to_cents
    self.amount = (self.amount*100).to_i
  end

  def amount_in_dollars
    self.amount/100.0
  end

end
