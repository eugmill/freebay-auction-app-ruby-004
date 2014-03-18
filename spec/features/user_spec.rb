require_relative '../feature_helper'

feature 'Part 2 User Feature Specs', :part_2_specs => true do
  feature 'User' do
    feature 'sign-up' do
      given!(:user) { build(:user) }

      scenario 'with a unique name' do
        visit new_user_path
        fill_in 'Name', with: user.name
        fill_in 'Password', with: user.password
        fill_in 'Password confirmation', with: user.password
        find('input[type="submit"]').click
        expect(current_path).to eq('/auctions')
        expect(page).to have_text('Successfully signed up!')
      end

      scenario 'with an already-used name' do
        User.create(name: user.name, password: "test", password_confirmation: "test")
        visit new_user_path
        fill_in 'Name', with: user.name
        fill_in 'Password', with: user.password
        fill_in 'Password confirmation', with: user.password
        find('input[type="submit"]').click
        expect(page).to have_text('There is already a user with that name.')
      end
    end
  end
end