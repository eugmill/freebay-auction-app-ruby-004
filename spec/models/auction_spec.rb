require 'spec_helper'

describe 'Part 1 Auction Model Specs', :part_1_specs => true do
  describe Auction do
    context 'an Auction\'s relationships to Bids and Users' do
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

      it 'belongs to a seller' do
        expect(@auction.seller).to eq(@avi)
      end

      it 'also has many bids' do
        expect(@auction.bids).to include(@bid)
      end
    end
    
    context 'deleting an auction' do
      let!(:auction) { create(:auction) }
      before do
        5.times do |i|
          auction.bids.create(amount: i+1)
        end
      end

      it 'deletes all bids associated with the auction' do
        auction.destroy
        expect(Bid.all.count).to eq(0)
      end
    end
  end
end