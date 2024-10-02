# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Visitor Features' do
  feature 'Browse Albums' do
    let!(:album_one) do
      create(:album, title: 'Track One', artist: 'Artist One')
    end
    let!(:album_two) do
      create(:album, title: 'Track Two', artist: 'Artist Two')
    end

    scenario 'Viewing the album index page content' do
      visit albums_path

      aggregate_failures do
        expect(page).to have_css('h1', text: 'Albums')
        within('table') do
          within('thead') do
            within('tr') do
              expect(page).to have_css('th', text: 'Title')
              expect(page).to have_css('th', text: 'Artist')
              expect(page).to have_css('th', exact_text: '', count: 1)
            end
          end
          within('tbody') do
            expect(page).to have_css('tr', count: 2)

            within('tr:nth-child(1)') do
              expect(page).to have_css('td', text: album_one.title)
              expect(page).to have_css('td', text: album_one.artist)
              expect(page).to have_link('Show')
              expect(page).to have_link('Edit')
              expect(page).to have_button('Delete')
            end

            within('tr:nth-child(2)') do
              expect(page).to have_css('td', text: album_two.title)
              expect(page).to have_css('td', text: album_two.artist)
              expect(page).to have_link('Show')
              expect(page).to have_link('Edit')
              expect(page).to have_button('Delete')
            end
          end
        end
        expect(page).to have_link('New Album')
      end
    end

    scenario 'Redirecting from the root page to the tracks page' do
      visit root_path

      expect(page).to have_current_path(albums_path, ignore_query: true)
    end
  end

  feature 'View Album Details' do
    let!(:album_one) do
      create(:album, title: 'Album One', artist: 'Artist One')
    end

    scenario 'Viewing a album show page content' do
      visit album_path(album_one)

      aggregate_failures do
        expect(page).to have_css('h1', text: 'Album')
        expect(page).to have_css('p', text: "Title: #{album_one.title}")
        expect(page).to have_css('p', text: "Artist: #{album_one.artist}")
        expect(page).to have_link('Edit')
        expect(page).to have_link('Tracklist')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Navigating to a album show page from the index page' do
      visit albums_path

      click_on 'Show', match: :first

      expect(page).to have_current_path(album_path(album_one), ignore_query: true)
    end

    scenario 'Navigating back to the album index page from the show page' do
      visit album_path(album_one)
      click_on 'Back'

      expect(page).to have_current_path(albums_path, ignore_query: true)
    end
  end

  feature 'Create New Album' do
    scenario 'Viewing the new album form page' do
      visit new_album_path

      aggregate_failures do
        expect(page).to have_css('h1', text: 'New Album')
        expect(page).to have_field('Title')
        expect(page).to have_field('Artist')
        expect(page).to have_button('Create Album')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Creating a new album with valid details' do
      visit new_album_path

      fill_in 'Title', with: 'New Album'
      fill_in 'Artist', with: 'New Artist'
      click_on 'Create Album'

      expect(Album.last).to have_attributes(title: 'New Album', artist: 'New Artist')
      expect(page).to have_current_path(albums_path, ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Album was successfully created.')
      expect(page).to have_css('tbody tr', count: 1)
    end

    scenario 'Creating a new album with missing title', :js do
      visit new_album_path

      fill_in 'Artist', with: 'New Artist'
      click_on 'Create Album'

      expect(Album.count).to eq(0) # No new album should be created
      message = page.find_by_id('album_title').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Creating a new album with missing artist', :js do
      visit new_album_path

      fill_in 'Title', with: 'New Title'
      click_on 'Create Album'

      expect(Album.count).to eq(0) # No new album should be created
      message = page.find_by_id('album_artist').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Navigating to the new album page from the index page' do
      visit albums_path

      click_on 'New Album'

      expect(page).to have_current_path(new_album_path, ignore_query: true)
    end

    scenario 'Navigating back to the album index page from the new album page' do
      visit new_album_path

      click_on 'Back'

      expect(page).to have_current_path(albums_path, ignore_query: true)
    end
  end

  feature 'Edit Album' do
    let!(:album) do
      create(:album, title: 'Sample Album', artist: 'Sample Artist')
    end

    scenario 'Viewing the edit album form page' do
      visit edit_album_path(album)

      aggregate_failures do
        expect(page).to have_css('h1', text: 'Edit Album')
        expect(page).to have_field('Title', with: album.title)
        expect(page).to have_field('Artist', with: album.artist)
        expect(page).to have_button('Update Album')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Updating a album with valid details' do
      visit edit_album_path(album)

      expect do
        fill_in 'Title', with: 'Updated Album'
        fill_in 'Artist', with: 'Updated Artist'
        click_on 'Update Album'
      end.not_to change(Album, :count)

      album.reload
      expect(album).to have_attributes(title: 'Updated Album', artist: 'Updated Artist')
      expect(page).to have_current_path(album_path(album), ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Album was successfully updated.')
    end

    scenario 'Updating a album with missing title', :js do
      visit edit_album_path(album)

      fill_in 'Title', with: ''
      click_on 'Update Album'

      album.reload
      expect(album.title).to eq('Sample Album') # Album should not be updated
      message = page.find_by_id('album_title').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Updating a album with missing artist', :js do
      visit edit_album_path(album)

      fill_in 'Artist', with: ''
      click_on 'Update Album'

      album.reload
      expect(album.artist).to eq('Sample Artist') # Album should not be updated
      message = page.find_by_id('album_artist').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Navigating to a album edit page from the index page' do
      visit albums_path

      click_on 'Edit', match: :first

      expect(page).to have_current_path(edit_album_path(album), ignore_query: true)
    end

    scenario 'Navigating to a album edit page from the show page' do
      visit album_path(album)

      click_on 'Edit'

      expect(page).to have_current_path(edit_album_path(album), ignore_query: true)
    end

    scenario 'Navigating back to the album index page from the edit page' do
      visit edit_album_path(album)

      click_on 'Back'

      expect(page).to have_current_path(albums_path, ignore_query: true)
    end
  end

  feature 'Destroy Album' do
    let!(:album) { create(:album) }

    scenario 'Deleting an album from the index page' do
      visit albums_path

      expect(page).to have_content(album.title)
      expect do
        click_on 'Delete', match: :first
      end.to change(Album, :count).by(-1)

      expect(page).to have_current_path(albums_path, ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Album was successfully destroyed.')
      expect(page).to have_no_content(album.title)
    end
  end

  feature 'Browse Tracks' do
    let(:album) { Album.create!(title: 'Album Title', artist: 'Album Artist') }
    let!(:track_one) do
      create(:track, title: 'Track One', length_in_seconds: 250, album:)
    end
    let!(:track_two) do
      create(:track, title: 'Track Two', length_in_seconds: 300, album:)
    end

    scenario 'Viewing the track index page content' do
      visit album_tracks_path(album)

      aggregate_failures do
        expect(page).to have_css('h1', text: "#{album.title} Tracks")
        within('table') do
          within('thead') do
            within('tr') do
              expect(page).to have_css('th', text: 'Title')
              expect(page).to have_css('th', text: 'Length')
              expect(page).to have_css('th', exact_text: '', count: 1)
            end
          end
          within('tbody') do
            expect(page).to have_css('tr', count: 2)

            within('tr:nth-child(1)') do
              expect(page).to have_css('td', text: track_one.title)
              expect(page).to have_css('td', text: track_one.length_in_seconds)
              expect(page).to have_link('Show')
              expect(page).to have_link('Edit')
              expect(page).to have_button('Delete')
            end

            within('tr:nth-child(2)') do
              expect(page).to have_css('td', text: track_two.title)
              expect(page).to have_css('td', text: track_two.length_in_seconds)
              expect(page).to have_link('Show')
              expect(page).to have_link('Edit')
              expect(page).to have_button('Delete')
            end
          end
        end
        expect(page).to have_link('New Track')
      end
    end

    scenario 'Navigating to the track index page from the album show page' do
      visit album_path(album)

      click_on 'Tracklist'

      expect(page).to have_current_path(album_tracks_path(album), ignore_query: true)
    end

    scenario 'Navigating back to the album show page from the track index page' do
      visit album_tracks_path(album)

      click_on 'Back to Album'

      expect(page).to have_current_path(album_path(album), ignore_query: true)
    end
  end

  feature 'View Track Details' do
    let(:album) { Album.create!(title: 'Album Title', artist: 'Album Artist') }
    let!(:track_one) do
      create(:track, title: 'Track One', length_in_seconds: 250, album:)
    end

    scenario 'Viewing a track show page content' do
      visit album_track_path(album, track_one)

      aggregate_failures do
        expect(page).to have_css('h1', text: 'Track')
        expect(page).to have_css('p', text: "Title: #{track_one.title}")
        expect(page).to have_css('p', text: "Length: #{track_one.length_in_seconds}")
        expect(page).to have_link('Back')
      end
    end

    scenario 'Navigating to a track show page from the index page' do
      visit album_tracks_path(album)

      click_on 'Show', match: :first

      expect(page).to have_current_path(album_track_path(album, track_one), ignore_query: true)
    end

    scenario 'Navigating back to the track index page from the show page' do
      visit album_track_path(album, track_one)
      click_on 'Back'

      expect(page).to have_current_path(album_tracks_path(album), ignore_query: true)
    end
  end

  feature 'Create New Track' do
    let(:album) { Album.create!(title: 'Album Title', artist: 'Album Artist') }

    scenario 'Viewing the new track form page' do
      visit new_album_track_path(album)

      aggregate_failures do
        expect(page).to have_css('h1', text: "New Track for #{album.title}")
        expect(page).to have_field('Title')
        expect(page).to have_field('Length in seconds')
        expect(page).to have_button('Create Track')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Creating a new track with valid details' do
      visit new_album_track_path(album)

      fill_in 'Title', with: 'New Track'
      fill_in 'Length in seconds', with: 200
      click_on 'Create Track'

      expect(Track.last).to have_attributes(title: 'New Track', length_in_seconds: 200)
      expect(page).to have_current_path(album_tracks_path(album), ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Track was successfully created.')
      expect(page).to have_css('tbody tr', count: 1)
    end

    scenario 'Creating a new track with missing title', :js do
      visit new_album_track_path(album)

      fill_in 'Length in seconds', with: 200
      click_on 'Create Track'

      expect(Track.count).to eq(0) # No new track should be created
      message = page.find_by_id('track_title').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Creating a new track with invalid length' do
      visit new_album_track_path(album)

      fill_in 'Title', with: 'New Track'
      fill_in 'Length in seconds', with: 0
      click_on 'Create Track'

      expect(Track.count).to eq(0) # No new track should be created
      expect(page).to have_css('.alert-danger', text: 'Error! Unable to create track.')
      expect(page).to have_content('Length in seconds must be greater than 0', normalize_ws: true)
    end

    scenario 'Navigating to the new track page from the index page' do
      visit album_tracks_path(album)

      click_on 'New Track'

      expect(page).to have_current_path(new_album_track_path(album), ignore_query: true)
    end

    scenario 'Navigating back to the track index page from the new page' do
      visit new_album_track_path(album)

      click_on 'Back'

      expect(page).to have_current_path(album_tracks_path(album), ignore_query: true)
    end
  end

  feature 'Edit Track' do
    let(:album) { Album.create!(title: 'Album Title', artist: 'Album Artist') }
    let!(:track) do
      create(:track, title: 'Sample Track', length_in_seconds: 180, album:)
    end

    scenario 'Viewing the edit track form page' do
      visit edit_album_track_path(album, track)

      aggregate_failures do
        expect(page).to have_css('h1', text: "Edit Track for #{album.title}")
        expect(page).to have_field('Title', with: track.title)
        expect(page).to have_field('Length in seconds', with: track.length_in_seconds)
        expect(page).to have_button('Update Track')
        expect(page).to have_link('Back')
      end
    end

    scenario 'Updating a track with valid details' do
      visit edit_album_track_path(album, track)

      fill_in 'Title', with: 'Updated Track'
      fill_in 'Length in seconds', with: 200
      click_on 'Update Track'

      track.reload
      expect(track).to have_attributes(title: 'Updated Track', length_in_seconds: 200)
      expect(page).to have_current_path(album_track_path(album, track), ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Track was successfully updated.')
    end

    scenario 'Updating a track with missing title', :js do
      visit edit_album_track_path(album, track)

      fill_in 'Title', with: ''
      click_on 'Update Track'

      track.reload
      expect(track.title).to eq('Sample Track') # Track should not be updated
      message = page.find_by_id('track_title').native.attribute('validationMessage')
      expect(message).to eq 'Please fill out this field.'
    end

    scenario 'Updating a track with invalid length' do
      visit edit_album_track_path(album, track)

      fill_in 'Length in seconds', with: 0
      click_on 'Update Track'

      track.reload
      expect(track.length_in_seconds).to eq(180) # Track should not be updated
      expect(page).to have_css('.alert-danger', text: 'Error! Unable to update track.')
      expect(page).to have_content('Length in seconds must be greater than 0', normalize_ws: true)
    end

    scenario 'Navigating to a track edit page from the index page' do
      visit album_tracks_path(album)

      click_on 'Edit', match: :first

      expect(page).to have_current_path(edit_album_track_path(album, track), ignore_query: true)
    end

    scenario 'Navigating back to the track index page from the edit page' do
      visit edit_album_track_path(album, track)

      click_on 'Back'

      expect(page).to have_current_path(album_tracks_path(album), ignore_query: true)
    end
  end

  feature 'Destroy Track' do
    let(:album) { Album.create!(title: 'Album Title', artist: 'Album Artist') }
    let!(:track) do
      create(:track, title: 'Sample Track', length_in_seconds: 180, album:)
    end

    scenario 'Deleting a track from the index page' do
      visit album_tracks_path(album)

      expect(page).to have_content(track.title)
      expect do
        click_on 'Delete', match: :first
      end.to change(Track, :count).by(-1)

      expect(page).to have_current_path(album_tracks_path(album), ignore_query: true)
      expect(page).to have_css('.alert-success', text: 'Track was successfully destroyed.')
      expect(page).to have_no_content(track.title)
    end
  end
end
