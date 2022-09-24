require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  before :each do
    @merchant_1 = Merchant.create!(name: "Bread Pitt")

    @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
    @customer_2 = Customer.create!(first_name: "Shannon", last_name: "Dougherty")
    @customer_3 = Customer.create!(first_name: "Puff", last_name: "Daddy")

    @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: 30.minutes.ago)
    @invoice_2 = Invoice.create!(status: 2, customer_id: @customer_2.id, created_at: 15.minutes.ago)
    @invoice_3 = Invoice.create!(status: 2, customer_id: @customer_3.id, created_at: 5.minutes.ago)

    @item_1 = Item.create!(name: "Sourdough", description: "leavened, wild yeast", unit_price: 400, merchant_id: @merchant_1.id)
    @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 900, merchant_id: @merchant_1.id)
    @item_3 = Item.create!(name: "Brioche", description: "Rich, rolled", unit_price: 1100, merchant_id: @merchant_1.id)

    @invoice_item_1 = InvoiceItem.create!(quantity: 4, unit_price: 850, status: 0, item_id: @item_1.id, invoice_id: @invoice_1.id)
    @invoice_item_2 = InvoiceItem.create!(quantity: 2, unit_price: 1300, status: 1, item_id: @item_2.id, invoice_id: @invoice_2.id)
    @invoice_item_3 = InvoiceItem.create!(quantity: 3, unit_price: 999, status: 2, item_id: @item_3.id, invoice_id: @invoice_3.id)
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:status) }
  end

  describe 'relationships' do
    it { should belong_to(:item) }
    it { should belong_to(:invoice) }
    it { should have_many(:merchants).through(:item) }
    it { should have_many(:transactions).through(:invoice) }
    it { should have_many(:customers).through(:invoice) }
    it { should have_many(:bulk_discounts).through(:item) }
  end

  describe 'Incomplete Invoices' do
    it 'displays the incomplete_invoices id number' do
      expect(InvoiceItem.incomplete_invoices).to eq([@invoice_1, @invoice_2])
    end
    it 'displays the incomplete invoices in ascending order' do
      expect(InvoiceItem.incomplete_invoices.first).to eq(@invoice_1)
    end
  end

  describe '#applied discounts' do
    it 'will show which discounts were used if any' do
      @merchant_1 = Merchant.create!(name: "Bread Pitt")
      @merchant_2 = Merchant.create!(name: "Carrie Breadshaw")
      @item_1 = Item.create!(name: "Sourdough", description: "leavened, wild yeast", unit_price: 400, merchant_id: @merchant_1.id)
      @item_2 = Item.create!(name: "Baguette", description: "Soft, french", unit_price: 100, merchant_id: @merchant_1.id)
      @item_4 = Item.create!(name: "Bread Roll", description: "Round, soft", unit_price: 100, merchant_id: @merchant_2.id, status: 1)
      @customer_1 = Customer.create!(first_name: "Meat", last_name: "Loaf")
      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id, created_at: Time.parse("Friday, September, 16, 2022"))
      @invoice_item_1 = InvoiceItem.create!(quantity: 12, unit_price: 100, status: 2, item_id: @item_1.id, invoice_id: @invoice_1.id)
      @invoice_item_2 = InvoiceItem.create!(quantity: 15, unit_price: 100, status: 1, item_id: @item_2.id, invoice_id: @invoice_1.id)
      @invoice_item_3 = InvoiceItem.create!(quantity: 5, unit_price: 100, status: 2, item_id: @item_4.id, invoice_id: @invoice_1.id)
      @discount_a = BulkDiscount.create!(percentage_discount: 20, quantity: 10, merchant_id: @merchant_1.id)
      @discount_b = BulkDiscount.create!(percentage_discount: 30, quantity: 15, merchant_id: @merchant_1.id)
      @discount_c = BulkDiscount.create!(percentage_discount: 30, quantity: 15, merchant_id: @merchant_2.id)

      expect(@invoice_item_1.applied_discount).to eq(@discount_a)
      expect(@invoice_item_2.applied_discount).to eq(@discount_b)
      expect(@invoice_item_3.applied_discount).to_not eq(@discount_c)
    end
  end
end
