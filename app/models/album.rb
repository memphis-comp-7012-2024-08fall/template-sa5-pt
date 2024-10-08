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
class Album < ApplicationRecord
  validates :title, :artist, presence: true
end
