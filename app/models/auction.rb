class Auction < ActiveRecord::Base
  has_many :bids
  belongs_to :seller, :class_name => "User"
end
