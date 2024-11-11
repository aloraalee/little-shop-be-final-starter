require "rails_helper"

describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:discount_type)}
    it { should validate_presence_of(:discount_value)}
    it { should allow_value(true).for(:active) }
    it { should allow_value(false).for(:active) }
    it { should_not allow_value(nil).for(:active) }    
    it { should validate_numericality_of(:discount_value).is_greater_than_or_equal_to(0)}
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoices }
  end

  describe "Merchant coupons endpoints" do
    before :each do
      @merchant1 = create(:merchant)
      @coupon1 = create(:coupon, merchant_id: @merchant1.id)
      @coupon2 = create(:coupon, merchant_id: @merchant1.id)
      @coupon3 = create(:coupon, merchant_id: @merchant1.id)
      @coupon4 = create(:coupon, merchant_id: @merchant1.id)
      @coupon5 = create(:coupon, merchant_id: @merchant1.id)

      @invoice_m1_1 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon1.id)
      @invoice_m1_2 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon1.id)
      @invoice_m1_3 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon2.id)
      @invoice_m1_4 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon3.id)
      @invoice_m1_5 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon3.id)
    end
    
    it "returns an error if you try to add more than five coupons to a merchant" do
      coupon6 = create(:coupon, merchant_id: @merchant1.id)

      expect(Coupon.merchant_active_coupon_limit?(@merchant1)).to eq(true)
    end

    it "returns the serialized coupon with usage count" do
      result = @coupon1.serialized_with_usage_count

      expect(result).to be_a(Hash)
      expect(result[:data]).to be_present
      expect(result[:data][:id]).to eq(@coupon1.id.to_s)
      expect(result[:data][:type]).to eq(:coupon)
      expect(result[:data][:attributes]).to include(
        :name,
        :code,
        :discount_type,
        :discount_value,
        :active,
        :merchant_id
      )
      expect(result[:meta]).to be_present
      expect(result[:meta][:coupon_used_count]).to eq(2)
    end
  end
end