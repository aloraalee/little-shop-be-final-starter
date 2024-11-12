require "rails_helper"

RSpec.describe Invoice do
  it { should belong_to :merchant }
  it { should belong_to :customer }
  it { should belong_to(:coupon).optional }
  it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }
end

describe "Merchant coupons endpoints" do
  before :each do
    @merchant1 = create(:merchant)
    @coupon1 = create(:coupon, merchant_id: @merchant1.id)
    @coupon2 = create(:coupon, merchant_id: @merchant1.id)
    @coupon3 = create(:coupon, merchant_id: @merchant1.id)
    @coupon4 = create(:coupon, merchant_id: @merchant1.id)
    @coupon5 = create(:coupon, merchant_id: @merchant1.id)

    @merchant2 = create(:merchant)

    @invoice_m1_1 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon1.id)
    @invoice_m1_2 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon1.id)
    @invoice_m1_3 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon2.id)
    @invoice_m1_4 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon3.id)
    @invoice_m1_5 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon3.id)
  end

  it "returns an error if you try to add an invoice with a coupon that doesn't belong to that merchant" do
    expect {
      create(:invoice, merchant_id: @merchant2.id, coupon_id: @coupon1.id)
    }.to raise_error(ActiveRecord::RecordInvalid, /This merchant does not have this coupon/)
  end
end