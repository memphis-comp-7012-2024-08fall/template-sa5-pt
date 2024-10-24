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
FactoryBot.define do
  factory :album do
    title { 'my album' }
    artist { 'my artist'}
  end
end
