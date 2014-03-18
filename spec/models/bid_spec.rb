require 'spec_helper'

describe 'Part 1 Bid Model Specs', :part_1_specs => true do
  describe Bid do
    context 'a Bid\'s relationships to Users and Auctions' do
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

      it 'belongs to a bidder' do
        expect(@bid.bidder).to eq(@spencer)
      end

      it 'also belongs to an auction' do
        expect(@bid.auction).to eq(@auction)
      end
    end

    context '#amount' do
      before do
        seller = User.create(name: "Bobby")
        @auction = Auction.create(title: 'Title', description: 'Description', end_time: Time.now, seller: seller)
      end

      it 'is initialized with dollars' do
        unsaved_bid = Bid.new(auction_id: @auction.id, amount: 100)
        expect(unsaved_bid.amount).to eq(100)
      end

      it 'stores its amount in cents' do
        saved_bid = Bid.create(auction_id: @auction.id, amount: 500)
        expect(Bid.all.first.amount).to eq(50000)
      end
    end

    context '#amount_in_dollars' do
      before do
        seller = User.create(name: "Avi")
        @auction = Auction.create(title: 'Title', description: 'Description', end_time: Time.now, seller: seller)
      end

      it 'returns the amount in dollars' do
        saved_bid = Bid.create(auction_id: @auction.id, amount: 1000)
        expect(Bid.all.first.amount_in_dollars).to eq(1000)
      end
    end
  end
end