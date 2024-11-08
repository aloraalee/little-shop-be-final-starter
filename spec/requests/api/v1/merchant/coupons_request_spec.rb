require "rails_helper"

RSpec.describe "Merchant couponss endpoints" do
  it "should return all coupons for a given merchant" do
    merchant1 = create(:merchant)
    coupon1 = create(:coupon, merchant_id: merchant1.id)
    coupon2 = create(:coupon, merchant_id: merchant1.id)
    coupon3 = create(:coupon, merchant_id: merchant1.id)
    merchant2 = create(:merchant)
    coupon4= create(:coupon, merchant_id: merchant2.id)

    get "/api/v1/merchants/#{merchant1.id}/coupons"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(3)
    expect(json[:data][0][:id]).to eq(coupon1.id.to_s)
    expect(json[:data][1][:id]).to eq(coupon2.id.to_s)
    expect(json[:data][2][:id]).to eq(coupon3.id.to_s)
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