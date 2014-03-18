require_relative '../feature_helper'

feature 'Part 1 Auction Feature Specs', :part_1_specs => true do
  given!(:user) { create(:user) }

  before(:each) do
    login_with(user.id)
  end

  feature 'Auction' do
    feature 'new auction' do
      given!(:auction) { build(:auction) }

      scenario 'with a valid title' do
        visit new_auction_path

        fill_in 'Title', with: auction.title
        fill_in 'Description', with: auction.description
        fill_in 'End Date', with: auction.end_time

        find('input[type="submit"]').click
        expect(current_path).to eq(auction_path(Auction.all.first))
        expect(page).to have_text(auction.title)
      end

      scenario 'with an already-used title' do
        test_auction = Auction.create(title: auction.title, end_time: Time.now)
        unless test_auction.persisted?
          Auction.create(title: auction.title, end_time: Time.now, seller_id: 0)
        end
        visit new_auction_path

        fill_in 'Title', with: auction.title
        fill_in 'Description', with: 'I\'m trying to pull a fast one!'
        fill_in 'End Date', with: auction.end_time

        find('input[type="submit"]').click
        expect(current_path).to eq('/auctions')
        expect(page).to have_text('Title has already been taken')
      end

      scenario 'without an end date' do
        visit new_auction_path

        fill_in 'Title', with: auction.title
        fill_in 'Description', with: auction.description

        find('input[type="submit"]').click
        expect(current_path).to eq('/auctions')
        expect(page).to have_text('End time can\'t be blank')
      end
    end

    feature 'all auctions' do
      before do
        Timecop.freeze(Chronic.parse("Jan 1 2014"))
      end

      test_auction = Auction.create(title: "Auction-Test", end_time: Chronic.parse("Jan 31 2014"))
      if test_auction.persisted?
        let!(:active_auction) { Auction.create(title: "Auction-1", end_time: Chronic.parse("Jan 2 2014")) }
        let!(:ended_auction) { Auction.create(title: "Auction-2", end_time: Chronic.parse("Dec 31 2013")) }
      else
        let!(:active_auction) { Auction.create(title: "Auction-1", end_time: Chronic.parse("Jan 2 2014"), seller_id: 0) }
        let!(:ended_auction) { Auction.create(title: "Auction-2", end_time: Chronic.parse("Dec 31 2013"), seller_id: 0) }
      end
      scenario 'displays all active auctions' do
        visit auctions_path
        expect(page).to have_css("a[href='#{auction_path(active_auction)}']")
        expect(page).to_not have_css("a[href='#{auction_path(ended_auction)}']")
      end
      
    end

    feature 'view auction' do
      given!(:auction) { create(:auction) }
      given!(:low_bid) { create(:low_bid) }
      given!(:mid_bid) { create(:mid_bid) }
      given!(:high_bid) { create(:high_bid) }

      before(:each) do
        User.find_or_create_by(id: high_bid.bidder_id).update(name: "Avi Flombaum", password: "test", password_confirmation: "test")
      end

      after(:each) do
        Timecop.return
      end

      context 'an active auction' do
        before(:each) do
          Timecop.freeze(Chronic.parse("Jan 30 2014"))
          visit auction_path(auction)
        end

        scenario 'displays a high bid' do
          expect(page.text).to match(/\$2,000.00[^\d]*/)
        end

        scenario 'displays the title' do
          expect(page).to have_text(auction.title)
        end

        scenario 'displays the description' do
          expect(page).to have_text(auction.description)
        end

        scenario 'displays the time remaining in the auction' do
          expect(page).to have_text("2 days left")
        end

        scenario 'shows the high bidder\'s name' do
          expect(page).to have_text("Avi Flombaum")
        end
      end

      context 'an auction that has ended' do
        before(:each) do
          Timecop.freeze(Chronic.parse("Feb 2 2014"))
          visit auction_path(auction)
        end

        scenario 'says that the auction has ended' do
          expect(page).to_not have_text("2 days left")
          expect(page).to have_text("Auction has ended")
        end
      end
    end

    feature 'edit auction' do
      given!(:auction) { create(:auction) }
      given!(:user) { User.create(id: auction.seller_id, name: "User Name", password: "test", password_confirmation: "test") }
      
      before(:each) do
        login_with(user.id)
      end

      after(:each) do
        Timecop.return
      end

      scenario 'an active auction' do
        Timecop.freeze(Chronic.parse("Jan 1 2014"))
        visit edit_auction_path(auction)

        fill_in 'Description', with: 'This is an updated description'
        find('input[type="submit"]').click
        expect(page).to have_text('Auction successfully updated')
        expect(current_path).to eq(auction_path(auction)) 
      end

      scenario 'an ended auction' do
        Timecop.freeze(Chronic.parse("Feb 2 2014"))
        visit edit_auction_path(auction)

        expect(page).to_not have_css('form')
        expect(page).to have_text('Auction has ended')
      end
    end

    feature 'delete an auction' do
      given!(:auction) { create(:auction) }
      given!(:user) { User.create(id: auction.seller_id, name: "Seller Name", password: "test", password_confirmation: "test") }

      before(:each) do
        login_with(user.id)
      end

      after(:each) do
        Timecop.return
      end

      scenario 'ending an auction early' do
        Timecop.freeze(Chronic.parse("Jan 1 2014"))
        visit edit_auction_path(auction)

        click_link('End Auction Early')
        expect(page).to have_text('Successfully ended auction early.')
        expect(current_path).to eq(auctions_path)
      end

      scenario 'deleting an already ended auction' do
        Timecop.freeze(Chronic.parse("Feb 2 2014"))
        visit edit_auction_path(auction)

        click_link('Delete Auction')
        expect(page).to have_text('Successfully deleted auction.')
        expect(current_path).to eq(auctions_path)
      end
    end

    feature 'place bid' do
      given!(:auction) { create(:auction) }
      given!(:high_bid) { create(:high_bid) }

      before(:each) do
        visit new_auction_bid_path(auction)
      end

      scenario 'that\'s too low' do
        fill_in 'Amount', with: high_bid.amount/100 - 10
        find('input[type="submit"]').click
        expect(page).to have_text('Amount is too low!')
      end

      scenario 'a new high bid' do
        fill_in 'Amount', with: high_bid.amount + 1000
        find('input[type="submit"]').click
        expect(page).to have_text('You are the current high bidder!')
        expect(current_path).to eq(auction_path(auction))
      end

      scenario 'an invalid bid' do
        fill_in 'Amount', with: '1,203'
        find('input[type="submit"]').click
        expect(page).to have_text('Amount is not a number')
      end

      scenario 'on an auction that has ended' do
        ended_auction = create(:auction)
        visit new_auction_bid_path(ended_auction)
        Timecop.freeze(Chronic.parse("Feb 2 2014")) do
          fill_in 'Amount', with: '3000'
          find('input[type="submit"]').click
          expect(page).to have_text('Auction has ended')
        end
      end
    end
  end
end

feature 'Part 2 Auction Feature Specs', :part_2_specs => true do
  feature 'Auction' do
    feature 'new auction' do
      given!(:auction) { build(:auction) }
      given!(:user) { create(:user) }

      before do
        Timecop.freeze(Chronic.parse("Jan 1 1990"))
      end

      after do
        Timecop.return
      end

      scenario 'with a logged in user' do
        login_with(user.id)
        visit new_auction_path

        fill_in 'Title', with: auction.title
        fill_in 'Description', with: auction.description
        fill_in 'End Date', with: auction.end_time

        find('input[type="submit"]').click
        expect(current_path).to eq(auction_path(Auction.all.first))
        expect(page).to have_text(auction.title)
      end

      scenario 'without a logged in user' do
        login_with(nil)
        visit new_auction_path

        fill_in 'Title', with: 'Different title'
        fill_in 'Description', with: auction.description
        fill_in 'End Date', with: auction.end_time

        find('input[type="submit"]').click
        expect(current_path).to eq(login_path)
      end
    end

    feature 'placing a bid' do
      given!(:auction) { create(:auction) }
      
      context 'with a logged in user' do
        given!(:user) { create(:user) }

        scenario 'on another user\'s auction' do
          login_with(user.id)
          visit new_auction_bid_path(auction)
          fill_in 'Amount', with: 2000
          find('input[type="submit"]').click
          expect(page).to have_text('You are the current high bidder!')
        end

        scenario 'on an auction created by the logged in user' do
          User.create(id: auction.seller_id, name: 'random_user', password: "test", password_confirmation: "test")
          login_with(auction.seller_id)
          visit new_auction_bid_path(auction)
          fill_in 'Amount', with: 2000
          find('input[type="submit"]').click
          expect(page).to have_text('You cannot bid on your own auction.')
        end
      end

      context 'without a logged in user' do
        scenario 'trying to place a bid without being logged in' do
          login_with(nil)
          visit new_auction_bid_path(auction)
          fill_in 'Amount', with: 2000
          find('input[type="submit"]').click
          expect(page).to have_text('Log In')
        end
      end
    end
  end
end

feature 'Part 3 Auction Feature Specs', :part_3_specs => true do
  feature 'Auction' do
    let!(:auction) { create(:auction) }
    let!(:user_1) { User.create(id: auction.seller_id, name: 'user_1', password: "test", password_confirmation: "test") }
    let!(:user_2) { User.create(id: auction.seller_id + 1, name: 'user_2', password: "test", password_confirmation: "test") }
    given!(:auction_with_image) { build(:auction) }
    given!(:user_with_image) { create(:user) }

    before(:each) do
      Timecop.freeze(Chronic.parse("Jan 1 1990"))
    end

    after(:each) do
      Timecop.return
      FileUtils.rm_rf(File.expand_path('public/images'))
    end

    feature 'creating a new auction' do
      scenario 'with an uploaded image' do
        create_auction(user_with_image.id, auction_with_image.title, auction_with_image.description, auction_with_image.end_time)
        
        expect(current_path).to eq(auction_path(Auction.all.last))
        expect(page).to have_text(auction_with_image.title)
      end
    end

    feature 'viewing an auction' do
      scenario 'that has an attached image' do
        create_auction(user_with_image.id, auction_with_image.title, auction_with_image.description, auction_with_image.end_time)
        visit auction_path(Auction.all.last)

        expect(page).to have_css("img[src*='test.png']")
      end
    end

    feature 'editing an auction' do
      scenario 'that the user owns' do
        login_with(auction.seller_id)
        visit edit_auction_path(auction)
        fill_in 'Description', with: 'Updated! I own this one!'
        find('input[type="submit"]').click
        expect(page).to have_text('Auction successfully updated')
      end

      scenario 'that belongs to a different user' do
        login_with(auction.seller_id + 1)
        visit edit_auction_path(auction)
        expect(page).to have_text("Log In")
      end
    end

    feature 'deleting an auction' do
      scenario 'that the user owns' do
        login_with(auction.seller_id)
        visit edit_auction_path(auction)
        click_link('End Auction Early')
        expect(page).to have_text('Successfully ended auction early.')
      end
    end
  end
end