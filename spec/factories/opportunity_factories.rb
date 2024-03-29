FactoryGirl.define do

  sequence :opportunity_status do |s|
    %w(prospecting analysis presentation proposal negotiation final_review won lost).sample
  end

  sequence :opportunity_open_status do |s|
    %w(prospecting analysis presentation proposal negotiation final_review).sample
  end

  factory :opportunity, class: FatFreeCrm::Opportunity do
    user
    campaign
    account             { FactoryGirl.create(:account) }
    assigned_to         nil
    name                { Faker::Lorem.sentence[0,64] }
    access              "Public"
    source              { %w(campaign cold_call conference online referral self web word_of_mouth other).sample }
    stage               { FactoryGirl.generate(:opportunity_status) }
    probability         { rand(50) }
    amount              { rand(1000) }
    discount            { rand(100) }
    closes_on           { FactoryGirl.generate(:date) }
    background_info     { Faker::Lorem.paragraph[0,255] }
    deleted_at          nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end

  factory :opportunity_in_pipeline, :parent => :opportunity do
    stage               { FactoryGirl.generate(:opportunity_open_status) }
  end

end
