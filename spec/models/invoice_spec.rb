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

    it 'shows total discount when both item A (20%) and item B (30%) meet separate discounts criteria' do
      @merchant_1 = Merchant.create!(name: "Bread Pitt")
      @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 100, merchant_id: @merchant_1.id)
      @item_4 = Item.create!(name: "Bread Roll", description: "Round, soft", unit_price: 100, merchant_id: @merchant_1.id, status: 1)
      @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: Time.parse("Friday, September, 16, 2022"))
      @invoice_item_1 = InvoiceItem.create!(quantity: 12, unit_price: 100, status: 2, item_id: @item_2.id, invoice_id: @invoice_1.id)
      @invoice_item_2 = InvoiceItem.create!(quantity: 15, unit_price: 100, status: 1, item_id: @item_4.id, invoice_id: @invoice_1.id)
      #12 * 100 = 1200 * .2 = 240 - item A discount
      #15 * 100 = 1500 * .3 = 450 - item A discount
      @discount_a = BulkDiscount.create!(percentage_discount: 20, quantity: 10, merchant_id: @merchant_1.id)
      @discount_b = BulkDiscount.create!(percentage_discount: 30, quantity: 15, merchant_id: @merchant_1.id)

      expect(@invoice_1.discounted_revenue).to eq 690
    end

    it 'will discount both item A and item B at 20%, disregarding discount B at 15% because discount A was met first' do
      @merchant_1 = Merchant.create!(name: "Bread Pitt")
      @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 100, merchant_id: @merchant_1.id)
      @item_4 = Item.create!(name: "Bread Roll", description: "Round, soft", unit_price: 100, merchant_id: @merchant_1.id, status: 1)
      @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: Time.parse("Friday, September, 16, 2022"))
      @invoice_item_1 = InvoiceItem.create!(quantity: 12, unit_price: 100, status: 2, item_id: @item_2.id, invoice_id: @invoice_1.id)
      @invoice_item_2 = InvoiceItem.create!(quantity: 15, unit_price: 100, status: 1, item_id: @item_4.id, invoice_id: @invoice_1.id)
      #12 * 100 = 1200 * .2 = 240 - item A discount
      #15 * 100 = 1500 * .2 = 300 - item B discount
      #15 * 100 = 1500 * .15 = 225 - item B discount - should be ignored
      @discount_a = BulkDiscount.create!(percentage_discount: 20, quantity: 10, merchant_id: @merchant_1.id)
      @discount_b = BulkDiscount.create!(percentage_discount: 15, quantity: 15, merchant_id: @merchant_1.id)

      expect(@invoice_1.discounted_revenue).to eq 540
      expect(@invoice_1.discounted_revenue).to_not eq 465
    end

    it 'displays total discount where both item A should be 20% and item B 30% for merchant A, but the included item A for merchant B is not discounted' do
      @merchant_1 = Merchant.create!(name: "Bread Pitt")
      @merchant_2 = Merchant.create!(name: "Carrie Breadshaw")
      @item_1 = Item.create!(name: "Sourdough", description: "leavened, wild yeast", unit_price: 400, merchant_id: @merchant_1.id)
      @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 100, merchant_id: @merchant_1.id)
      @item_4 = Item.create!(name: "Bread Roll", description: "Round, soft", unit_price: 100, merchant_id: @merchant_2.id, status: 1)
      @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: Time.parse("Friday, September, 16, 2022"))
      @invoice_item_1 = InvoiceItem.create!(quantity: 12, unit_price: 100, status: 2, item_id: @item_1.id, invoice_id: @invoice_1.id)
      @invoice_item_2 = InvoiceItem.create!(quantity: 15, unit_price: 100, status: 1, item_id: @item_2.id, invoice_id: @invoice_1.id)
      @invoice_item_3 = InvoiceItem.create!(quantity: 15, unit_price: 100, status: 2, item_id: @item_4.id, invoice_id: @invoice_1.id)
      #12 * 100 = 1200 * .2 = 240 - item A discount
      #15 * 100 = 1500 * .3 = 450 - item B discount
      #merchant_2 does not have disounts
      #15 * 100 = 1500 * .2 = 300 - item A discount - should be ignored
      @discount_a = BulkDiscount.create!(percentage_discount: 20, quantity: 10, merchant_id: @merchant_1.id)
      @discount_b = BulkDiscount.create!(percentage_discount: 30, quantity: 15, merchant_id: @merchant_1.id)

      expect(@invoice_1.discounted_revenue).to eq 690
      expect(@invoice_1.discounted_revenue).to_not eq 990
    end

  end


end
