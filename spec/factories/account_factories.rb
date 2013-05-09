FactoryGirl.define do
  factory :account, class: FatFreeCrm::Account do
    user
    assigned_to         nil
    name                { Faker::Company.name + rand(100).to_s }
    access              "Public"
    website             { FactoryGirl.generate(:website) }
    email               { Faker::Internet.email }
    toll_free_phone     { Faker::PhoneNumber.phone_number }
    phone               { Faker::PhoneNumber.phone_number }
    fax                 { Faker::PhoneNumber.phone_number }
    background_info     { Faker::Lorem.paragraph[0,255] }
    deleted_at          nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end


  factory :account_contact, class: FatFreeCrm::AccountContact do
    account
    contact
    deleted_at          nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end


  factory :account_opportunity, class: FatFreeCrm::AccountOpportunity do
    account
    opportunity
    deleted_at          nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end
end
