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
    @coupon1 = create(:coupon, discount_type: "dollar", discount_value: 10, merchant_id: @merchant1.id)
    @coupon2 = create(:coupon, discount_type: "percent", discount_value: 20, merchant_id: @merchant1.id)
    @coupon3 = create(:coupon, merchant_id: @merchant1.id)
    @coupon4 = create(:coupon, merchant_id: @merchant1.id)
    @coupon5 = create(:coupon, merchant_id: @merchant1.id)

    @merchant2 = create(:merchant)

    @invoice_m1_1 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon1.id)
    @invoice_m1_2 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon1.id)
    @invoice_m1_3 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon2.id)
    @invoice_m1_4 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon3.id)
    @invoice_m1_5 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon3.id)

    @invoice_item_m1_1 = create(:invoice_item, quantity: 4, unit_price: 15, invoice_id: @invoice_m1_1.id)
    @invoice_item_m1_2 = create(:invoice_item, quantity: 3, unit_price: 10, invoice_id: @invoice_m1_3.id)
    @invoice_item_m1_3 = create(:invoice_item, quantity: 2, unit_price: 5, invoice_id: @invoice_m1_3.id)

  end

  it "returns an error if you try to add an invoice with a coupon that doesn't belong to that merchant" do
    invoice_m2_6 = build(:invoice, merchant_id: @merchant2.id, coupon_id: @coupon1.id)

    invoice_m2_6.valid?
    expect(invoice_m2_6.errors[:base]).to include("This merchant does not have this coupon")
  end

  it "should return the total for an invoice before a coupon is applied" do
    expect(@invoice_m1_1.calculate_total).to eq(60)
    expect(@invoice_m1_3.calculate_total).to eq(40)
  end

  it "should return the total for an invoice after a coupon is applied" do
    expect(@invoice_m1_1.calculate_total_after_discount).to eq(50)
    expect(@invoice_m1_3.calculate_total_after_discount).to eq(32)
  end

  it "should return 0 if discount is more than the total" do
    coupon6 = create(:coupon, discount_type: "dollar", discount_value: 20, merchant_id: @merchant1.id)
    invoice_m1_6 = create(:invoice, merchant_id: @merchant1.id, coupon_id: coupon6.id)
    invoice_item_m1_4 = create(:invoice_item, quantity: 1, unit_price: 15, invoice_id: invoice_m1_6.id)

    expect(invoice_m1_6.calculate_total_after_discount).to eq(0)
  end
end