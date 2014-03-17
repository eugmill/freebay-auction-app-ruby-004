class User < ActiveRecord::Base
  has_many :auctions
  has_many :bids, foreign_key: "bidder_id"
end
