require 'rails_helper'

RSpec.describe AccountTransaction, type: :model do
  it { should belong_to(:account) }

  it { should validate_presence_of(:transaction_type) }
  it { is_expected.to validate_inclusion_of(:transaction_type).in_array(AccountTransaction::TRANSACTION_TYPES) }
  it { should validate_presence_of(:status) }
  it { is_expected.to validate_inclusion_of(:status).in_array(AccountTransaction::STATUS_TYPES) }
  it { should validate_numericality_of(:transefered_amount) }
  it { should validate_presence_of(:transefered_amount) }
end
