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
FactoryBot.define do
  factory :track do
    album

    title { 'Song' }
    length_in_seconds { 2 }
  end
end
