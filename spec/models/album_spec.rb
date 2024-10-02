# frozen_string_literal: true

# == Schema Information
#
# Table name: albums
#
#  id         :bigint           not null, primary key
#  artist     :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Album do
  it 'has the correct non-string column types' do
    columns = ActiveRecord::Base.connection.columns(:tracks)

    expect(columns.find { |c| c.name == 'length_in_seconds' }.sql_type).to eq 'integer'
  end

  it 'has seeds' do
    load Rails.root.join('db/seeds.rb').to_s

    expect(described_class.count).to eq 3
    expect(described_class.order(:title).pluck(:title, :artist))
      .to eq [['Abbey Road', 'The Beatles'], ['Rumours', 'Fleetwood Mac'], ['The Dark Side of the Moon', 'Pink Floyd']]
  end
end
