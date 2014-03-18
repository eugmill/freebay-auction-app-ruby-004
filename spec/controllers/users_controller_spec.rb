require 'spec_helper'

describe 'Part 2 UsersController Specs', :part_2_specs => true do
  describe UsersController do
    describe 'GET new' do
      it 'renders the new template' do
        get :new
        expect(response).to render_template("new")
      end
    end

    describe 'POST create' do
      context 'with a unique name' do
        before do
          User.create(name: "Bob", password: "password", password_confirmation: "password")
          post :create, user: { name: "Tina", password: "password", password_confirmation: "password" }
        end

        it 'creates a new user' do
          expect(User.all.count).to eq(2)
          expect(User.all.last.name).to eq("Tina")
        end

        it 'redirects to the auctions page' do
          expect(response).to redirect_to(auctions_path)
        end
      end

      context 'with an already-claimed name' do
        before do
          User.create(name: "Bob", password: "password", password_confirmation: "password")
          post :create, user: { name: "Bob", password: "password", password_confirmation: "password" }
        end

        it 'doesn\'t create a new user' do
          expect(User.all.count).to eq(1)
        end

        it 'renders the signup page' do
          expect(response).to render_template('new')
        end
      end
    end
  end
end
