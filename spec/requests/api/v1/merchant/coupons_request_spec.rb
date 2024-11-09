require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
  before :each do
    @merchant1 = create(:merchant)
    @coupon1 = create(:coupon, merchant_id: @merchant1.id)
    @coupon2 = create(:coupon, merchant_id: @merchant1.id)
    @coupon3 = create(:coupon, merchant_id: @merchant1.id)
    
    @merchant2 = create(:merchant)
    @coupon4= create(:coupon, merchant_id: @merchant2.id)

    @invoice_m1_1 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon1.id)
    @invoice_m1_2 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon1.id)
    @invoice_m1_3 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon2.id)
    @invoice_m1_4 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon3.id)
    @invoice_m1_5 = create(:invoice, merchant_id: @merchant1.id, coupon_id:@coupon3.id)
  end

  describe "GET all coupons" do
    it "should return all coupons for a given merchant" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data].count).to eq(3)
      expect(json[:data][0][:id]).to eq(@coupon1.id.to_s)
      expect(json[:data][1][:id]).to eq(@coupon2.id.to_s)
      expect(json[:data][2][:id]).to eq(@coupon3.id.to_s)
    end
  end

  it "should return 404 and error message when merchant is not found" do
    get "/api/v1/merchants/100000/coupons"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(:not_found)
    expect(json[:message]).to eq("Your query could not be completed")
    expect(json[:errors]).to be_a Array
    expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
  end

  describe "GET coupon by id" do
    it "should return one coupon for a given merchant" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons/#{@coupon1.id}"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data]).to be_a(Hash)
      expect(json[:data][:id]).to eq("#{@coupon1.id}")
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes][:name]).to eq(@coupon1.name)
      expect(json[:data][:attributes][:code]).to eq(@coupon1.code)
      expect(json[:data][:attributes][:discount_type]).to eq(@coupon1.discount_type)
      expect(json[:data][:attributes][:discount_value]).to eq(@coupon1.discount_value)
      expect(json[:data][:attributes][:merchant_id]).to eq(@merchant1.id)
    end
  
    it "should return one coupon and show how many times that coupon has been used" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons/#{@coupon1.id}"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:meta]).to be_a(Hash)
      expect(json[:meta][:coupon_used_count]).to eq(2)
    end


    it "should return 404 and error message when coupon is not found" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons/100000"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Couldn't find Coupon with 'id'=100000 [WHERE \"coupons\".\"merchant_id\" = $1]")
    end
  end

  describe "POST coupon" do
    it "should create a new coupon for a given merchant when all fields are provided" do

      body1 = {
        name: "New Coupon",
        code: "GIVE5AWAY",
        discount_type: "dollar",
        discount_value: 5,
        merchant_id: @merchant1.id
      }
      
      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: body1, as: :json
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:name]).to eq(body1[:name])
      expect(json[:data][:attributes][:code]).to eq(body1[:code])
      expect(json[:data][:attributes][:discount_type]).to eq(body1[:discount_type])
      expect(json[:data][:attributes][:discount_value]).to eq(body1[:discount_value])
      expect(json[:data][:attributes][:merchant_id]).to eq(body1[:merchant_id])
    end

    it "should ignore unnecessary fields" do
      body1 = {
        name: "New Coupon",
        code: "GIVE5AWAY",
        discount_type: "dollar",
        discount_value: 5,
        extra_field: "malicious stuff",
        merchant_id: @merchant1.id
      }

      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: body1, as: :json
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes]).to_not include(:extra_field)
      expect(json[:data][:attributes]).to include(:name, :code, :discount_type, :discount_value, :merchant_id)
    end
  end
end