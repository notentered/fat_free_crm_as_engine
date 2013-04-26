FactoryGirl.define do
  factory :tag, class: FatFreeCrm::Tag do
    name { Faker::Internet.user_name }
  end
end