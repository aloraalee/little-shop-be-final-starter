require "rails_helper"

RSpec.describe "Merchant Coupon endpoints" do
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

    it "should return 404 and error message when merchant is not found" do
      get "/api/v1/merchants/100000/coupons"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
    end
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
      expect(json[:data][:attributes][:active]).to eq(@coupon1.active)
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

  describe "Create coupon" do
    it "should create a new coupon for a given merchant when all fields are provided" do

      body1 = {
        name: "New Coupon",
        code: "GIVE5AWAY",
        discount_type: "dollar",
        discount_value: 5,
        active: true,
        merchant_id: @merchant1.id
      }
      
      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: body1, as: :json
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:name]).to eq(body1[:name])
      expect(json[:data][:attributes][:code]).to eq(body1[:code])
      expect(json[:data][:attributes][:discount_type]).to eq(body1[:discount_type])
      expect(json[:data][:attributes][:discount_value]).to eq(body1[:discount_value])
      expect(json[:data][:attributes][:active]).to eq(body1[:active])
      expect(json[:data][:attributes][:merchant_id]).to eq(body1[:merchant_id])
    end

    it "should ignore unnecessary fields" do
      body1 = {
        name: "New Coupon",
        code: "GIVE5AWAY",
        discount_type: "dollar",
        discount_value: 5,
        active: true,
        extra_field: "malicious stuff",
        merchant_id: @merchant1.id
      }

      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: body1, as: :json
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes]).to_not include(:extra_field)
      expect(json[:data][:attributes]).to include(:name, :code, :discount_type, :discount_value, :active, :merchant_id)
    end

    it "should only be able to have five active coupons" do
      coupon4 = create(:coupon, merchant_id: @merchant1.id)
      coupon5 = create(:coupon, merchant_id: @merchant1.id)

      coupon6 = {
        name: "Mail in advertising",
        code: "COME2STORE",
        discount_type: "percent",
        discount_value: 20,
        active: true,
        merchant_id: @merchant1.id
      }

      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: coupon6, as: :json

      expect(response).to have_http_status(:too_many_requests)
    end

    it "should only add coupons that have a unique code" do
      coupon4 = {
        name: "Mail in advertising Oct",
        code: "COME2STORE",
        discount_type: "percent",
        discount_value: 20,
        active: true,
        merchant_id: @merchant1.id
      }

      coupon5 = {
        name: "Mail in advertising Nov",
        code: "COME2STORE",
        discount_type: "percent",
        discount_value: 20,
        active: true,
        merchant_id: @merchant1.id
      }

      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: coupon4, as: :json
      expect(response).to have_http_status(:created)

      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: coupon5, as: :json
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "Update a coupon" do
    it "should update a coupon's attributes" do
      updated_coupon4 = {
        name: "Mail in advertising Oct",
        code: "COME2STORE",
        discount_type: "percent",
        discount_value: 20,
        active: false,
        merchant_id: @merchant2.id
      }

      patch "/api/v1/merchants/#{@merchant2.id}/coupons/#{@coupon4.id}", params: { coupon:updated_coupon4 }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data]).to be_a(Hash)
      expect(json[:data][:id]).to eq("#{@coupon4.id}")
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes][:name]).to eq(updated_coupon4[:name])
      expect(json[:data][:attributes][:code]).to eq(updated_coupon4[:code])
      expect(json[:data][:attributes][:discount_type]).to eq(updated_coupon4[:discount_type])
      expect(json[:data][:attributes][:discount_value]).to eq(updated_coupon4[:discount_value])
      expect(json[:data][:attributes][:active]).to eq(updated_coupon4[:active])
      expect(json[:data][:attributes][:merchant_id]).to eq(@merchant2.id)
    end

    it "should update a coupon's active status with only that attribute" do
      updated_coupon3 = {
        active: false,
      }

      patch "/api/v1/merchants/#{@merchant1.id}/coupons/#{@coupon3.id}", params: { coupon:updated_coupon3 }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data]).to be_a(Hash)
      expect(json[:data][:id]).to eq("#{@coupon3.id}")
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes][:active]).to eq(updated_coupon3[:active])
      expect(json[:data][:attributes][:merchant_id]).to eq(@merchant1.id)
    end
    xit "should not be deactivated if there are pending invoices" do
      invoice_m2_1 = create(:invoice, merchant_id: @merchant2.id, coupon_id:@coupon4.id)

      updated_coupon4 = {
        name: "Mail in advertising Oct",
        code: "COME2STORE",
        discount_type: "percent",
        discount_value: 20,
        active: false,
        merchant_id: @merchant2.id
      }

      patch "/api/v1/merchants/#{@merchant2.id}/coupons/#{@coupon4.id}", params: { coupon:updated_coupon4 }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end