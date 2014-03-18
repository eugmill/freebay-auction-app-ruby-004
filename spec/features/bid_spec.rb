require_relative '../feature_helper'

feature 'Part 1 Bid Feature Specs', :part_1_specs => true do
  feature 'Bid' do
    feature 'viewing all bids on an auction' do
      given!(:avi) { User.create(:name => 'Avi', password: "test", password_confirmation: "test") }
      given!(:spencer) { User.create(:name => 'Spencer', password: "test", password_confirmation: "test") }
      given!(:arel) { User.create(:name => 'Arel', password: "test", password_confirmation: "test") }
      given!(:logan) { User.create(:name => 'Logan', password: "test", password_confirmation: "test") }
      given!(:auction_1) { Auction.create(:seller => avi,
                                          :title => 'This is an auction.',
                                          :description => 'Description.',
                                          :end_time => Chronic.parse('Feb 1 2014')
                                         )
                         }
      given!(:auction_2) { Auction.create(:seller => avi,
                                          :title => 'This is another auction.',
                                          :description => 'Another description.',
                                          :end_time => Chronic.parse('Feb 1 2014')
                                         )
                         }

      given!(:bid_1) { Bid.create(:bidder => spencer, :auction => auction_1, :amount => 100) }
      given!(:bid_2) { Bid.create(:bidder => arel, :auction => auction_1, :amount => 10000) }
      given!(:bid_3) { Bid.create(:bidder => logan, :auction => auction_2, :amount => 500) }

      before do
        Timecop.freeze(Chronic.parse('Jan 1 2014'))
        Bid.any_instance.stub(:created_at).and_return(Chronic.parse('Jan 31 2014'))
        visit auction_bids_path(auction_1)
      end

      after do
        Timecop.return
      end

      scenario 'displays the bidder name associated with each bid' do
        expect(page).to have_text('Spencer')
        expect(page).to have_text('Arel')
      end

      scenario 'displays the amount of each bid' do
        expect(page.text).to match(/\$100.00[^\d]*/)
        expect(page.text).to match(/\$10,000.00[^\d]*/)
      end

      scenario 'displays the time each bid was placed' do
        expect(page).to have_text("Fri, January 31, 2014 - 12:01:00 PM")
      end

      scenario 'displays a link to return to the auction show page' do
        expect(page).to have_css("a[href='#{auction_path(auction_1)}']")
      end

      scenario 'doesn\'t display bids associated with other auctions' do
        expect(page).to_not have_text('Logan')
        expect(page.text).to_not match(/\$500.00[^\d]*/)
      end
    end
  end
end