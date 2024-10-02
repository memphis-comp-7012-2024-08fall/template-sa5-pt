# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Dark Side of the Moon

Album.create!(
  title:  'The Dark Side of the Moon',
  artist: 'Pink Floyd'
)

Track.create!(
  title:             'Speak to Me / Breathe',
  length_in_seconds: (3 * 60) + 58
)

Track.create!(
  title:             'On the Run',
  length_in_seconds: (3 * 60) + 35
)

Track.create!(
  title:             'Time',
  length_in_seconds: (7 * 60) + 5
)

# Rumours

Album.create!(
  title:  'Rumours',
  artist: 'Fleetwood Mac'
)

Track.create!(
  title:             'Second Hand News',
  length_in_seconds: (2 * 60) + 48
)

Track.create!(
  title:             'Dreams',
  length_in_seconds: (4 * 60) + 39
)

Track.create!(
  title:             'Never Going Back Again',
  length_in_seconds: (2 * 60) + 14
)

# Abbey Road

Album.create!(
  title:  'Abbey Road',
  artist: 'The Beatles'
)

Track.create!(
  title:             'Come Together',
  length_in_seconds: (4 * 60) + 19
)

Track.create!(
  title:             'Something',
  length_in_seconds: (3 * 60) + 3
)

Track.create!(
  title:             'Maxwells Silver Hammer',
  length_in_seconds: (3 * 60) + 27
)
