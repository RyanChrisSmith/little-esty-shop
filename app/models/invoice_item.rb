class InvoiceItem < ApplicationRecord
  validates_presence_of :quantity, :unit_price, :status
  enum status: { pending: 0, packaged: 1, shipped: 2}

  belongs_to :item
  belongs_to :invoice
  has_many :merchants, through: :item
  has_many :transactions, through: :invoice
  has_many :customers, through: :invoice
  has_many :bulk_discounts, through: :item

  def self.incomplete_invoices
    inv_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(inv_ids)
  end

  def applied_discount
    bulk_discounts.where('bulk_discounts.quantity <= ?', quantity)
    .order(percentage_discount: :desc).first
  end
end
