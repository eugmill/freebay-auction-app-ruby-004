class User < ActiveRecord::Base
  has_many :auctions, foreign_key: "seller_id"
  has_many :bids, foreign_key: "bidder_id"
end
