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
#
class Track < ApplicationRecord
  validates :title, :length_in_seconds, presence: true
  validates :length_in_seconds, numericality: { greater_than: 0 }
end
