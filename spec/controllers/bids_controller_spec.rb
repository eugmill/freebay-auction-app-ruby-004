require 'spec_helper'

describe 'Part 1 BidsController Specs', :part_1_specs => true do
  let!(:user) { create(:user) }
  before do 
    create(:auction)
  end

  describe BidsController do
    describe 'GET new' do
      it 'renders the new template' do
        get :new, auction_id: 1
        expect(response).to render_template("new")
      end
    end

    describe 'POST create' do
      let!(:auction) { create(:auction) }
      let!(:bid) { build(:low_bid) }

      before(:each) do
        User.create(id: auction.seller_id, name: 'user_1', password: "test", password_confirmation: "test")
        User.create(id: auction.seller_id + 1, name: 'user_2', password: "test", password_confirmation: "test")
        use_user_id(auction.seller_id + 1)
      end

      context 'with a high enough amount' do
        before(:each) do
          auction.bids.create(:amount => bid.amount)
          post :create, { auction_id: auction.id, bid: {
                                                amount: bid.amount + 1000
                                               }
                        }
        end

        it 'creates a new bid' do
         
          expect(Bid.all.count).to eq(2)
        end

        it 'redirects to the auction page' do
          expect(response).to redirect_to(auction_path(auction))
        end
      end

      context 'with a bid lower than the current high bid' do
        before(:each) do
          auction.bids.create(:amount => bid.amount)
          post :create, { auction_id: auction.id, bid: {
                                                amount: bid.amount - 10
                                               }                         
                        }
        end

        it 'doesn\'t create a new bid' do
          expect(Bid.all.count).to eq(1)
        end

        it 'renders the new bid template' do
          expect(response).to render_template('new')
        end
      end
    end

    describe 'GET index' do
      let!(:auction) { create(:auction) }

      it 'renders the index template' do
        get :index, auction_id: auction.id
        expect(response).to render_template('index')
      end
    end
  end
end

describe 'Part 2 BidsController Specs', :part_2_specs => true do
  describe BidsController do
    describe 'POST create' do
      let!(:auction) { create(:auction) }
      let!(:user_1) { User.create(id: auction.seller_id, name: 'user_1', password: "test", password_confirmation: "test") }
      let!(:user_2) { User.create(id: auction.seller_id + 1, name: 'user_2', password: "test", password_confirmation: "test") }

      context 'with a logged in user' do
        context 'on another user\'s auction' do
          before do
            use_user_id(auction.seller_id + 1)
            post :create, { auction_id: auction.id, bid: { amount: 1000 } }
          end

          it 'places the bid' do
            expect(response).to redirect_to(auction_path(auction))
          end

        end

        context 'on the current user\'s auction' do
          before do
            use_user_id(auction.seller_id)
            post :create, { auction_id: auction.id, bid: { amount: 1000 } }
          end

          it 'doesn\'t place the bid' do
            expect(response).to redirect_to(auction_path(auction))
          end
        end
      end

      context 'without a logged in user' do
        before do
          use_user_id(nil)
          post :create, { auction_id: auction.id, bid: { amount: 1000 } }
        end

        it 'redirects to the login page' do
          expect(response).to redirect_to(login_path)
        end
      end
    end
  end
end