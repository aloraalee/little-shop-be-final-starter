FactoryBot.define do
  factory :coupon do
    name { Faker::Commerce.promotion_code }
    code { Faker::Alphanumeric.alphanumeric(number: 8, min_alpha: 3, min_numeric: 3).upcase }
    discount_type { ['percent', 'dollar'].sample }
    discount_value { discount_type == 'percent' ? Faker::Number.between(from: 10, to: 50) : Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    merchant
  end
end