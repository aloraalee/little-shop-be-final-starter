class InvoiceItemSerializer
  include JSONAPI::Serializer
  attributes :quantity, :unit_price, :invoice_id, :item_id
end
