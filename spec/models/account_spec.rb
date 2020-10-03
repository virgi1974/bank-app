require 'rails_helper'

RSpec.describe Account, type: :model do
  it { should belong_to(:customer) }
  it { should have_many(:account_transactions) }

  it { should validate_presence_of(:balance) }
  it { should validate_numericality_of(:balance) }
  it { should validate_presence_of(:account_number) }
end
