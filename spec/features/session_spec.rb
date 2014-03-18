require_relative '../feature_helper'

feature 'Part 2 Session Feature Specs', :part_2_specs => true do
  feature 'Authentication' do
    feature 'logging in' do
      given!(:user) { create(:user) }
      
      before(:each) do
        visit login_path
      end

      scenario 'with a correct password' do
        fill_in 'Name', with: user.name
        fill_in 'Password', with: user.password
        find('input[type="submit"]').click
        expect(page).to have_text('Successfully logged in!')
      end

      scenario 'with an incorrect password' do
        fill_in 'Name', with: user.name
        fill_in 'Password', with: 'Not the password'
        find('input[type="submit"]').click
        expect(page).to have_text('Name and password don\'t match.')
      end
    end

    feature 'logging out' do
      scenario 'with a logged-in user' do
        User.create(id: 1, password: "test", password_confirmation: "test")
        page.set_rack_session(user_id: 1)
        visit auctions_path
        click_link 'Log Out'
        expect(page).to have_text("Active Auctions")
      end
    end
  end
end