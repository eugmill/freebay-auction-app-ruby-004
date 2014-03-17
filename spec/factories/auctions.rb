FactoryGirl.define do
  sequence :title do |n|
    "Auction-#{n}"
  end

  sequence :description do |n|
    "This is description ##{n}."
  end

  sequence :seller_id do |n|
    n
  end

  factory :auction do
    seller_id
    title
    description
    end_time Chronic.parse("Feb 1 2014")
  end
end