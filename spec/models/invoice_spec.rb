require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:status) }
  end

  describe 'relationships' do
    it { should belong_to(:customer) }
    it { should have_many(:invoice_items) }
    it { should have_many(:transactions) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
  end

  it 'can calculate total revenue generated by an invoice' do
    @merchant_1 = Merchant.create!(name: "Bread Pitt")
    @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")

    @invoice_4 = Invoice.create!(status: 2, customer_id: @customer_1.id)
    @item_4 = Item.create!(name: "Bread Roll", description: "Round, soft", unit_price: 850, merchant_id: @merchant_1.id)
    @invoice_item_4 = InvoiceItem.create!(quantity: 4, unit_price: 960, status: 2, item_id: @item_4.id, invoice_id: @invoice_4.id)

    expect(@invoice_4.total_revenue).to eq(3840)
  end

  describe '#discounted_revenue' do
    it 'will not apply any discounts when attributes of discount have not been met' do
      @merchant_1 = Merchant.create!(name: "Bread Pitt")
      @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 100, merchant_id: @merchant_1.id)
      @item_4 = Item.create!(name: "Bread Roll", description: "Round, soft", unit_price: 100, merchant_id: @merchant_1.id, status: 1)
      @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: Time.parse("Friday, September, 16, 2022"))
      @invoice_item_1 = InvoiceItem.create!(quantity: 5, unit_price: 100, status: 2, item_id: @item_2.id, invoice_id: @invoice_1.id)
      @invoice_item_2 = InvoiceItem.create!(quantity: 5, unit_price: 100, status: 1, item_id: @item_4.id, invoice_id: @invoice_1.id)

      @discount = BulkDiscount.create!(percentage_discount: 10, quantity: 10, merchant_id: @merchant_1.id)

      expect(@invoice_1.discounted_revenue).to eq 0
    end

    it 'shows the discount when item A is discounted for 20% and item B is not discounted' do
      @merchant_1 = Merchant.create!(name: "Bread Pitt")
      @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 100, merchant_id: @merchant_1.id)
      @item_4 = Item.create!(name: "Bread Roll", description: "Round, soft", unit_price: 100, merchant_id: @merchant_1.id, status: 1)
      @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: Time.parse("Friday, September, 16, 2022"))
      @invoice_item_1 = InvoiceItem.create!(quantity: 10, unit_price: 100, status: 2, item_id: @item_2.id, invoice_id: @invoice_1.id)
      @invoice_item_2 = InvoiceItem.create!(quantity: 5, unit_price: 100, status: 1, item_id: @item_4.id, invoice_id: @invoice_1.id)

      @discount = BulkDiscount.create!(percentage_discount: 20, quantity: 10, merchant_id: @merchant_1.id)

      expect(@invoice_1.discounted_revenue).to eq 200
    end

  end


end
