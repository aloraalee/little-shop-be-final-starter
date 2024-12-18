class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons
    if params[:filter].present?
      render json: CouponSerializer.new(coupons.filtered_by_active(params))
      return
    end
    render json: CouponSerializer.new(coupons)
  end

  def show
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])
    render json: coupon.serialized_with_usage_count
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    if Coupon.merchant_active_coupon_limit?(merchant)
      render json: { error: "This merchant has reached the maximum limit of 5 active coupons." }, status: :too_many_requests
      return
    end
    coupon = merchant.coupons.create!(coupon_params)
    render json: CouponSerializer.new(coupon), status: :created
  end

  def update
    coupon = Coupon.find(params[:id])
    if coupon_params[:active] == false || coupon_params[:active] == 'false' 
      if Coupon.with_invoice_status.exists?(id: coupon.id)
        render json: { error: "This coupon has a pending invoice." }, status: :unprocessable_content
        return
      end
    end
    coupon.update!(coupon_params)
      render json: CouponSerializer.new(coupon), status: :ok
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :active, :merchant_id)
  end
end