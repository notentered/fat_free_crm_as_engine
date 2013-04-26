FactoryGirl.define do
  factory :list, class: FatFreeCrm::List do
    name           "Foo List"
    url            "/controller/action"
  end
end