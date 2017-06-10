FactoryGirl.define do
  factory :team do
    slug { FFaker::Lorem.world }
    user
  end
end
