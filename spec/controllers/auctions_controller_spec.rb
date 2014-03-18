require 'spec_helper' 

describe 'Part 1 AuctionsController Specs', :part_1_specs => true do
  let!(:user) { create(:user) }

  describe AuctionsController do
    before(:each) do
      use_user_id(user.id)
    end

    describe 'GET new' do
      it 'renders the new template' do
        get :new
        expect(response).to render_template("new")
      end
    end

    describe 'POST create' do

      context 'with a unique title' do
        before(:each) do
          post :create, { auction: {
                                    title: "Auction_1",
                                    description: "This is a description",
                                    end_time: Time.now
                                   }
                        }
        end

        it 'creates a new auction' do
          expect(Auction.all.count).to eq(1)
        end

        it 'redirects to the auctions page' do
          expect(response).to redirect_to(auction_path(Auction.all.first))
        end
      end

      context 'with a duplicate title' do
        before(:each) do
          Auction.create(title: "Auction_1", description: "This is a description", end_time: Time.now, seller_id: session[:user_id])
          post :create, { auction: {
                                    title: "Auction_1",
                                    description: 'Trying to pull a fast one!',
                                    end_time: Time.now
                                   }
                        }
        end

        it 'doesn\'t create a new auction' do
          expect(Auction.all.count).to eq(1)
        end

        it 'renders the new template' do
          expect(response).to render_template('new')
        end
      end

      context 'without an end date' do
        before(:each) do
          Auction.create(title: "Auction_1", description: "This is a description", end_time: Time.now, seller_id: session[:user_id])
          post :create, { auction: {
                                   title: "Auction_1",
                                   description: "This is a description."
                                  }
                       }
        end

        it 'doesn\'t create a new auction' do
          expect(Auction.all.count).to eq(1)
        end

        it 'renders the new template' do
          expect(response).to render_template('new')
        end
      end
    end
    
    describe 'GET show' do
      let!(:auction) { create(:auction) }

      it 'renders the show template' do
        get :show, { id: auction.id }
        expect(response).to render_template("show")
      end
    end

    describe 'GET index' do
      it 'renders the index template' do
        get :index
        expect(response).to render_template("index")
      end
    end

    describe 'GET edit' do
      let!(:auction) { create(:auction) }
      before(:each) do
        owner = User.create(id: auction.seller_id, name: "Name", password: "test", password_confirmation: "test")
        use_user_id(owner.id)
      end

      it 'renders the edit template' do
        get :edit, { id: auction.id }
        expect(response).to render_template("edit")
      end
    end

    describe 'PATCH update' do
      let!(:auction) { create(:auction) }
      before(:each) do
        owner = User.create(id: auction.seller_id, name: "Owner", password: "test", password_confirmation: "test")
        use_user_id(owner.id)
      end
      after(:each) do
        Timecop.return
      end

      context 'an active auction' do
        before(:each) do
          Timecop.freeze(Chronic.parse('Jan 1 2014'))
          patch :update, { id: auction.id, auction: {
                                                     title: "Auction_1",
                                                     description: "Updated.",
                                                     end_time: auction.end_time
                                                    }
                         }
        end

        it 'updates the auction' do
          expect(Auction.find_by(id: auction.id).description).to eq('Updated.')
        end

        it 'redirects to the auction\'s show page' do
          expect(response).to redirect_to(auction_path(auction))
        end
      end

      context 'an ended auction' do
        before(:each) do
          Timecop.freeze(Chronic.parse('Feb 2 2014'))
          patch :update, { id: auction.id, auction: {
                                                     title: "Auction_1",
                                                     description: "Updated.",
                                                     end_time: auction.end_time
                                                    }
                         }
        end

        it 'doesn\'t update the auction' do
          expect(Auction.find_by(id: auction.id).description).to_not eq("Updated.")
        end

        it 'renders the edit template' do
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy' do
      let!(:auction) { create(:auction) }

      before(:each) do
        owner = User.create(id: auction.seller_id, name: "Delete Owner", password: "test", password_confirmation: "test")
        use_user_id(owner.id)
      end

      after(:each) do
        Timecop.return
      end

      context 'an active auction' do
        before(:each) do
          Timecop.freeze(Chronic.parse('Jan 1 2014'))
          delete :destroy, { id: auction.id }
        end

        it 'destroys the auction' do
          expect(Auction.find_by(id: auction.id)).to eq(nil)
        end

        it 'redirects to the auctions index' do
          expect(response).to redirect_to(auctions_path)
        end
      end

      context 'an ended auction' do
        before(:each) do
          Timecop.freeze(Chronic.parse('Feb 2 2014'))
          delete :destroy, { id: auction.id }
        end

        it 'destroys the auction' do
          expect(Auction.find_by(id: auction.id)).to eq(nil)
        end

        it 'redirects to the auctions index' do
          expect(response).to redirect_to(auctions_path)
        end
      end

      context 'when destroy fails' do
        before do
          Auction.any_instance.stub(:destroy).and_return(false)
          Timecop.freeze(Chronic.parse('Feb 2 2014'))
          delete :destroy, { id: auction.id }
        end

        it 'renders the edit view' do
          expect(response).to render_template('edit')
        end
      end
    end

  end
end

describe 'Part 2 AuctionsController Specs', :part_2_specs => true do
  let!(:user) { create(:user) }

  describe AuctionsController do
    describe 'POST create' do
      context 'with a logged in user' do
        before(:each) do
          use_user_id(user.id)
          post :create, { auction: {
                                    title: "Auction_1",
                                    description: "This is a description",
                                    end_time: Time.now
                                   }
                        }
        end

        it 'creates the auction' do
          expect(response).to redirect_to(auction_path(Auction.all.first))
        end
      end

      context 'without a logged in user' do

        before do
          use_user_id(nil)
          post :create, { auction: {
                                    title: "Auction_1",
                                    description: "This is a description",
                                    end_time: Time.now
                                   }
                        }
        end

        it 'doesn\'t create the auction' do
          expect(response).to redirect_to(login_path)
        end
      end
    end
  end
end

describe 'Part 3 AuctionsController Specs', :part_3_specs => true do
  describe AuctionsController do
    describe 'DELETE destroy' do
      let!(:auction) { create(:auction) }
      let!(:user_1) { User.create(id: auction.seller_id, name: "user_1", password: "test", password_confirmation: "test") }
      let!(:user_2) { User.create(id: auction.seller_id + 1, name: "user_2", password: "test", password_confirmation: "test") }
      
      context 'with a logged in user' do
        context 'when the user owns the auction' do
          before(:each) do
            use_user_id(auction.seller_id)
            delete :destroy, { id: auction.id }
          end

          it 'deletes the auction' do
            expect(Auction.all.pluck(:id)).to_not include(auction.id)
            expect(response).to redirect_to(auctions_path)
          end
        end

        context 'when the auction belongs to a different user' do
          before(:each) do
            use_user_id(auction.seller_id + 1)
            delete :destroy, { id: auction.id }
          end

          it 'redirects to the login page' do
            expect(Auction.find(auction.id)).to_not be(nil)
            expect(response).to redirect_to(login_path)
          end
        end
      end

      context 'without a logged in user' do
        before(:each) do
          use_user_id(nil)
          delete :destroy, { id: auction.id }
        end

        it 'redirects to the login page' do
          expect(Auction.find(auction.id)).to_not be(nil)
          expect(response).to redirect_to(login_path)
        end
      end
    end

    describe 'PATCH update' do
      let!(:auction) { create(:auction) }
      let!(:user_1) { User.create(id: auction.seller_id, name: "user_1", password: "test", password_confirmation: "test") }
      let!(:user_2) { User.create(id: auction.seller_id + 1, name: "user_2", password: "test", password_confirmation: "test") }

      context 'with a logged in user' do
        before(:each) do
          Timecop.freeze(Chronic.parse("Jan 1 2014"))
        end

        after(:each) do
          Timecop.return
        end

        
        context 'when the user owns the auction' do
          before(:each) do
            use_user_id(auction.seller_id)
            patch :update, id: auction.id, auction: { description: "Updated." }
          end

          it 'updates the auction' do
            expect(Auction.find(auction.id).description).to eq("Updated.")
          end

          it 'redirects to the auction show page' do
            expect(response).to redirect_to(auction_path(auction))
          end
        end

        context 'when the auction belongs to a different user' do
          before(:each) do
            use_user_id(auction.seller_id + 1)
            patch :update, id: auction.id, auction: { description: "Updated." }
          end

          it 'does not update the auction' do
            expect(Auction.find(auction.id).description).to_not eq("Updated.")
          end

          it 'redirects to the login page' do
            expect(response).to redirect_to(login_path)
          end
        end
      end

      context 'without a logged in user' do
        before(:each) do
          use_user_id(nil)
          patch :update, id: auction.id, auction: { description: "Updated." }
        end

        it 'does not update the auction' do
          expect(Auction.find(auction.id).description).to_not eq("Updated.")
        end

        it 'redirects to the login page' do
          expect(response).to redirect_to(login_path)
        end
      end
    end
  end
end