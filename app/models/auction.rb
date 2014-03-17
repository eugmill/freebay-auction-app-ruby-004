class Auction < ActiveRecord::Base
  has_many :bids, :dependent => :destroy
  belongs_to :seller, :class_name => "User"


end
