FactoryGirl.define do
  factory :low_bid, class: Bid do
    bidder_id 1
    auction_id 1
    amount 100
  end

  factory :mid_bid, class: Bid do
    bidder_id 2
    auction_id 1
    amount 500
  end

  factory :high_bid, class: Bid do
    bidder_id 3
    auction_id 1
    amount 2000
  end
end
