FactoryGirl.define do
  factory :setting, class: FatFreeCrm::Setting do
    name                "foo"
    value               nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end
end