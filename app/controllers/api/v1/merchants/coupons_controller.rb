class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons
    render json: CouponSerializer.new(coupons)
  end

  def show
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])
    serialized_coupon =  CouponSerializer.new(coupon).serializable_hash

    show_coupon_used_count = {
      data: serialized_coupon[:data],
      meta: {
        coupon_used_count: coupon.invoices.count
      }
    }
    render json: show_coupon_used_count
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    # Does this need to be taken out of the controller and put in the model?
    if merchant.coupons.where(active: true).count >= 5
      render json: { error: "This merchant has reached the maximum limit of 5 active coupons." }, status: :too_many_requests
      return
    end
    coupon = merchant.coupons.create!(coupon_params)
    render json: CouponSerializer.new(coupon), status: :created
  end

  def update
    coupon = Coupon.find(params[:id])
    if coupon.update!(coupon_params)
      render json: CouponSerializer.new(coupon), status: :ok
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :active, :merchant_id)
  end
end