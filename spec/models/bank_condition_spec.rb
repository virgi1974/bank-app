require 'rails_helper'

RSpec.describe BankCondition, type: :model do
  it { should belong_to(:bank) }

  it { should validate_presence_of(:external_bank_number) }
  it { should validate_presence_of(:commission) }
  it { should validate_numericality_of(:commission) }
  it { should validate_presence_of(:max_amount) }
  it { should validate_numericality_of(:max_amount) }
  it { should validate_presence_of(:min_amount) }
  it { should validate_numericality_of(:min_amount) }
  it { should validate_presence_of(:transaction_type) }
  it { is_expected.to validate_inclusion_of(:transaction_type).in_array(BankCondition::TRANSACTION_TYPES) }
end
