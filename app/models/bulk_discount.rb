class BulkDiscount < ApplicationRecord
  validates :percentage_discount, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 99 }
  validates :quantity, presence: true, numericality: true

  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
end