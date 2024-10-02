# frozen_string_literal: true

# == Schema Information
#
# Table name: tracks
#
#  id                :bigint           not null, primary key
#  length_in_seconds :integer
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  album_id          :bigint
#
# Indexes
#
#  index_tracks_on_album_id  (album_id)
#
# Foreign Keys
#
#  fk_rails_...  (album_id => albums.id)
#
require 'rails_helper'

RSpec.describe Track do
  it 'has the correct non-string column types' do
    columns = ActiveRecord::Base.connection.columns(:tracks)

    expect(columns.find { |c| c.name == 'length_in_seconds' }.sql_type).to eq 'integer'
  end

  it 'has seeds' do
    load Rails.root.join('db/seeds.rb').to_s

    expect(described_class.count).to eq 9

    album_ids = Album.pluck(:id)
    expect(described_class.order(:title).pluck(:title, :length_in_seconds, :album_id))
      .to eq [['Come Together', 259, album_ids[2]],
              ['Dreams', 279, album_ids[1]],
              ['Maxwells Silver Hammer', 207, album_ids[2]],
              ['Never Going Back Again', 134, album_ids[1]],
              ['On the Run', 215, album_ids[0]],
              ['Second Hand News', 168, album_ids[1]],
              ['Something', 183, album_ids[2]],
              ['Speak to Me / Breathe', 238, album_ids[0]],
              ['Time', 425, album_ids[0]]]
  end
end
