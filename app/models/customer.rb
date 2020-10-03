class Customer < ApplicationRecord
  belongs_to :bank
  has_many :accounts

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :idn, presence: true, uniqueness: :true
end
