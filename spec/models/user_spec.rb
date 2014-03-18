require 'spec_helper'

describe 'Part 1 User Model Specs', :part_1_specs => true do
  describe User do
    context 'a User\'s relationships to Auctions and Bids' do
      before(:each) do
        Timecop.freeze(Chronic.parse("Jan 1 2030"))
        @avi = User.create(name: "Avi", password: "password", password_confirmation: "password")
        @spencer = User.create(name: "Spencer", password: "password", password_confirmation: "password")
        @auction = @avi.listings.create(title: "Auction", description: "Description!", end_time: Time.now)
        @bid = @auction.bids.create(bidder_id: @spencer.id, amount: 1000)
      end

      after do
        Timecop.return
      end

      it 'has many listings' do
        expect(@avi.listings).to include(@auction)
      end

      it 'also has many bids' do
        expect(@spencer.bids).to include(@bid)
      end
    end
  end
end