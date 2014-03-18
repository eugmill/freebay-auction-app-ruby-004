# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :name do |n|
    "User_#{n}"
  end

  factory :user do
    name
    password "password"
    password_confirmation "password"
  end
end
