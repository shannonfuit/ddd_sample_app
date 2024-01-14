# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:name) { Faker::Name.name }

  it 'creates a valid factory' do
    FactoryBot.create(:company, name:)
    expect(described_class.first).to have_attributes(name: name)
  end
end
