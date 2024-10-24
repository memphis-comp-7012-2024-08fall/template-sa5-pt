# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Visitor Features' do
  let!(:album_one) { create(:album, title: 'Brat', artist: 'Charli XCX') }
  let!(:album_two) { create(:album, title: 'Hit Me Hard and Soft', artist: 'Billie Eilish') }

  feature 'Albums' do
    feature 'Browse Albums' do
      scenario 'Viewing the album index page content' do
        visit albums_path

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: 'Albums')
          within('table') do
            within('thead') do
              expect(page).to have_css('tr', count: 1)
              within('tr') do
                expect(page).to have_css('th', count: 3)
                expect(page).to have_css('th', exact_text: 'Title')
                expect(page).to have_css('th', exact_text: 'Artist')
                expect(page).to have_css('th', exact_text: '', count: 1)
              end
            end
            within('tbody') do
              # expect(page).to have_css('tr', count: 2)

              within('tr:nth-child(1)') do
                expect(page).to have_css('td', count: 3)

                expect(page).to have_css('td', exact_text: album_one.title)
                expect(page).to have_css('td', exact_text: album_one.artist)
                expect(page).to have_link('Show')
                expect(page).to have_link('Edit')
                expect(page).to have_button('Delete')
              end

              within('tr:nth-child(2)') do
                expect(page).to have_css('td', count: 3)

                expect(page).to have_css('td', exact_text: album_two.title)
                expect(page).to have_css('td', exact_text: album_two.artist)
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
      scenario 'Viewing a album show page content' do
        visit album_path(album_one)

        aggregate_failures do
          expect(page).to have_css('h1', count: 1)
          expect(page).to have_css('p', count: 4)
          expect(page).to have_css('a', count: 3)

          expect(page).to have_css('h1', exact_text: 'Album')
          expect(page).to have_css('p', exact_text: "Title: #{album_one.title}")
          expect(page).to have_css('p', exact_text: "Artist: #{album_one.artist}")
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
          expect(page).to have_css('h1', exact_text: 'New Album')
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
        expect(page).to have_css('.alert-success', exact_text: 'Album was successfully created.')
        expect(page).to have_css('tbody tr', count: 3)
      end

      scenario 'Creating a new album with missing title', :js do
        visit new_album_path

        expect do
          fill_in 'Artist', with: 'New Artist'
          click_on 'Create Album'
        end.not_to change(Album, :count)

        message = page.find_by_id('album_title').native.attribute('validationMessage')
        expect(message).to match(/Please fill (out|in) this field\./)
      end

      scenario 'Creating a new album with missing artist', :js do
        visit new_album_path

        expect do
          fill_in 'Title', with: 'New Title'
          click_on 'Create Album'
        end.not_to change(Album, :count)

        message = page.find_by_id('album_artist').native.attribute('validationMessage')
        expect(message).to match(/Please fill (out|in) this field\./)
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
      scenario 'Viewing the edit album form page' do
        visit edit_album_path(album_two)

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: 'Edit Album')
          expect(page).to have_field('Title', with: album_two.title)
          expect(page).to have_field('Artist', with: album_two.artist)
          expect(page).to have_button('Update Album')
          expect(page).to have_link('Back')
        end
      end

      scenario 'Updating a album with valid details' do
        visit edit_album_path(album_two)

        expect do
          fill_in 'Title', with: 'Updated Album'
          fill_in 'Artist', with: 'Updated Artist'
          click_on 'Update Album'
        end.not_to change(Album, :count)

        album_two.reload
        expect(album_two).to have_attributes(title: 'Updated Album', artist: 'Updated Artist')
        expect(page).to have_current_path(album_path(album_two), ignore_query: true)
        expect(page).to have_css('.alert-success', exact_text: 'Album was successfully updated.')
      end

      scenario 'Updating a album with missing title', :js do
        visit edit_album_path(album_two)

        fill_in 'Title', with: ''
        click_on 'Update Album'

        album_two.reload
        expect(album_two.title).to eq('Hit Me Hard and Soft') # Album should not be updated
        message = page.find_by_id('album_title').native.attribute('validationMessage')
        expect(message).to match(/Please fill (out|in) this field\./)
      end

      scenario 'Updating a album with missing artist', :js do
        visit edit_album_path(album_two)

        fill_in 'Artist', with: ''
        click_on 'Update Album'

        album_two.reload
        expect(album_two.artist).to eq('Billie Eilish') # Album should not be updated
        message = page.find_by_id('album_artist').native.attribute('validationMessage')
        expect(message).to match(/Please fill (out|in) this field\./)
      end

      scenario 'Navigating to a album edit page from the index page' do
        visit albums_path

        click_on 'Edit', match: :first

        expect(page).to have_current_path(edit_album_path(album_one), ignore_query: true)
      end

      scenario 'Navigating to a album edit page from the show page' do
        visit album_path(album_one)

        click_on 'Edit'

        expect(page).to have_current_path(edit_album_path(album_one), ignore_query: true)
      end

      scenario 'Navigating back to the album index page from the edit page' do
        visit edit_album_path(album_one)

        click_on 'Back'

        expect(page).to have_current_path(albums_path, ignore_query: true)
      end
    end

    feature 'Destroy Album' do
      scenario 'Deleting an album from the index page' do
        visit albums_path

        expect(page).to have_content(album_one.title)
        expect do
          click_on 'Delete', match: :first
        end.to change(Album, :count).by(-1)

        expect(page).to have_current_path(albums_path, ignore_query: true)
        expect(page).to have_css('.alert-success', exact_text: 'Album was successfully destroyed.')
        expect(page).to have_no_content(album_one.title)
      end
    end
  end

  feature 'Tracks' do
    let!(:track_one) do
      create(:track, title: '360', length_in_seconds: 133, album: album_one)
    end
    let!(:track_two) do
      create(:track, title: 'Girl, So Confusing', length_in_seconds: 174, album: album_one)
    end
    let!(:track_three) do
      create(:track, title: 'Lunch', length_in_seconds: 179, album: album_two)
    end

    feature 'Browse Tracks' do
      scenario 'Viewing the album_one track index page content' do
        visit album_tracks_path(album_one)

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: "#{album_one.title} Tracks")
          within('table') do
            within('thead') do
              within('tr') do
                expect(page).to have_css('th', exact_text: 'Title')
                expect(page).to have_css('th', exact_text: 'Length')
                expect(page).to have_css('th', exact_text: '', count: 1)
              end
            end
            within('tbody') do
              expect(page).to have_css('tr', count: 2)

              within('tr:nth-child(1)') do
                expect(page).to have_css('td', exact_text: track_one.title)
                expect(page).to have_css('td', exact_text: track_one.length_in_seconds)
                expect(page).to have_link('Show')
                expect(page).to have_link('Edit')
                expect(page).to have_button('Delete')
              end

              within('tr:nth-child(2)') do
                expect(page).to have_css('td', exact_text: track_two.title)
                expect(page).to have_css('td', exact_text: track_two.length_in_seconds)
                expect(page).to have_link('Show')
                expect(page).to have_link('Edit')
                expect(page).to have_button('Delete')
              end
            end
          end
          expect(page).to have_link('New Track')
          expect(page).to have_no_content(track_three.title)
        end
      end

      scenario 'Navigating to the track index page from the album_one show page' do
        visit album_path(album_one)

        click_on 'Tracklist'

        expect(page).to have_current_path(album_tracks_path(album_one), ignore_query: true)
      end

      scenario 'Navigating back to the album_one show page from the track index page' do
        visit album_tracks_path(album_one)

        click_on 'Back to Album'

        expect(page).to have_current_path(album_path(album_one), ignore_query: true)
      end

      scenario 'Viewing the album_two track index page content' do
        visit album_tracks_path(album_two)

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: "#{album_two.title} Tracks")
          within('table') do
            within('thead') do
              within('tr') do
                expect(page).to have_css('th', exact_text: 'Title')
                expect(page).to have_css('th', exact_text: 'Length')
                expect(page).to have_css('th', exact_text: '', count: 1)
              end
            end
            within('tbody') do
              expect(page).to have_css('tr', count: 1)

              within('tr:nth-child(1)') do
                expect(page).to have_css('td', exact_text: track_three.title)
                expect(page).to have_css('td', exact_text: track_three.length_in_seconds)
                expect(page).to have_link('Show')
                expect(page).to have_link('Edit')
                expect(page).to have_button('Delete')
              end
            end
          end
          expect(page).to have_link('New Track')
          expect(page).to have_no_content(track_one.title)
          expect(page).to have_no_content(track_two.title)
        end
      end

      scenario 'Navigating to the track index page from the album_two show page' do
        visit album_path(album_two)

        click_on 'Tracklist'

        expect(page).to have_current_path(album_tracks_path(album_two), ignore_query: true)
      end

      scenario 'Navigating back to the album_two show page from the track index page' do
        visit album_tracks_path(album_two)

        click_on 'Back to Album'

        expect(page).to have_current_path(album_path(album_two), ignore_query: true)
      end
    end

    feature 'View Track Details' do
      scenario 'Viewing a album_one track show page content' do
        visit album_track_path(album_one, track_two)

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: 'Track')
          expect(page).to have_css('p', exact_text: "Title: #{track_two.title}")
          expect(page).to have_css('p', exact_text: "Length: #{track_two.length_in_seconds}")
          expect(page).to have_link('Back')

          expect(page).to have_no_content(track_one.title)
          expect(page).to have_no_content(track_three.title)
        end
      end

      scenario 'Navigating to a album_one track show page from the album_one index page' do
        visit album_tracks_path(album_one)

        click_on 'Show', match: :first

        expect(page).to have_current_path(album_track_path(album_one, track_one), ignore_query: true)
      end

      scenario 'Navigating back to the track index page from the show page' do
        visit album_track_path(album_one, track_one)
        click_on 'Back'

        expect(page).to have_current_path(album_tracks_path(album_one), ignore_query: true)
      end

      scenario 'Viewing a album_two track show page content' do
        visit album_track_path(album_two, track_three)

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: 'Track')
          expect(page).to have_css('p', exact_text: "Title: #{track_three.title}")
          expect(page).to have_css('p', exact_text: "Length: #{track_three.length_in_seconds}")
          expect(page).to have_link('Back')
        end
      end

      scenario 'Navigating to a album_two track show page from the album_two index page' do
        visit album_tracks_path(album_two)

        click_on 'Show', match: :first

        expect(page).to have_current_path(album_track_path(album_two, track_three), ignore_query: true)
      end

      scenario 'Navigating back to the album_two track index page from the show page' do
        visit album_track_path(album_two, track_three)
        click_on 'Back'

        expect(page).to have_current_path(album_tracks_path(album_two), ignore_query: true)
      end

      scenario 'Navigating to the track show page using unrelated album and track ids' do
        expect { visit album_track_path(album_one, track_three) }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    feature 'Create New Track' do
      scenario 'Viewing the new album_one track form page' do
        visit new_album_track_path(album_one)

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: "New Track for #{album_one.title}")
          expect(page).to have_field('Title')
          expect(page).to have_field('Length in seconds')
          expect(page).to have_button('Create Track')
          expect(page).to have_link('Back')
        end
      end

      scenario 'Creating a new album_one track with valid details' do
        visit new_album_track_path(album_one)

        expect do
          fill_in 'Title', with: 'New Track'
          fill_in 'Length in seconds', with: 200
          click_on 'Create Track'
        end.to change(Track, :count).by 1

        expect(Track.last).to have_attributes(title: 'New Track', length_in_seconds: 200)
        expect(page).to have_current_path(album_tracks_path(album_one), ignore_query: true)
        expect(page).to have_css('.alert-success', exact_text: 'Track was successfully created.')
        expect(page).to have_css('tbody tr', count: 3)
      end

      scenario 'Viewing the new album_two track form page' do
        visit new_album_track_path(album_two)

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: "New Track for #{album_two.title}")
          expect(page).to have_field('Title')
          expect(page).to have_field('Length in seconds')
          expect(page).to have_button('Create Track')
          expect(page).to have_link('Back')
        end
      end

      scenario 'Creating a new album_two track with valid details' do
        visit new_album_track_path(album_two)

        expect do
          fill_in 'Title', with: 'New Track'
          fill_in 'Length in seconds', with: 200
          click_on 'Create Track'
        end.to change(Track, :count).by 1

        expect(Track.last).to have_attributes(title: 'New Track', length_in_seconds: 200)
        expect(page).to have_current_path(album_tracks_path(album_two), ignore_query: true)
        expect(page).to have_css('.alert-success', exact_text: 'Track was successfully created.')
        expect(page).to have_css('tbody tr', count: 2)
      end

      scenario 'Creating a new track with missing title', :js do
        visit new_album_track_path(album_one)

        expect do
          fill_in 'Length in seconds', with: 200
          click_on 'Create Track'
        end.not_to change(Track, :count)

        message = page.find_by_id('track_title').native.attribute('validationMessage')
        expect(message).to match(/Please fill (out|in) this field\./)
      end

      scenario 'Creating a new track with invalid length' do
        visit new_album_track_path(album_one)

        expect do
          fill_in 'Title', with: 'New Track'
          fill_in 'Length in seconds', with: 0
          click_on 'Create Track'
        end.not_to change(Track, :count)

        expect(page).to have_css('.alert-danger', exact_text: 'Error! Unable to create track.')
        expect(page).to have_content('Length in seconds must be greater than 0', normalize_ws: true)
      end

      scenario 'Navigating to the new track page from the album_one index page' do
        visit album_tracks_path(album_one)

        click_on 'New Track'

        expect(page).to have_current_path(new_album_track_path(album_one), ignore_query: true)
      end

      scenario 'Navigating back to the album_one track index page from the new page' do
        visit new_album_track_path(album_one)

        click_on 'Back'

        expect(page).to have_current_path(album_tracks_path(album_one), ignore_query: true)
      end

      scenario 'Navigating to the new track page from the album_two index page' do
        visit album_tracks_path(album_two)

        click_on 'New Track'

        expect(page).to have_current_path(new_album_track_path(album_two), ignore_query: true)
      end

      scenario 'Navigating back to the track index page from the new page' do
        visit new_album_track_path(album_two)

        click_on 'Back'

        expect(page).to have_current_path(album_tracks_path(album_two), ignore_query: true)
      end
    end

    feature 'Edit Track' do
      scenario 'Viewing the edit album_one track form page' do
        visit edit_album_track_path(album_one, track_two)

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: "Edit Track for #{album_one.title}")
          expect(page).to have_field('Title', with: track_two.title)
          expect(page).to have_field('Length in seconds', with: track_two.length_in_seconds)
          expect(page).to have_button('Update Track')
          expect(page).to have_link('Back')
        end
      end

      scenario 'Updating a album_one track with valid details' do
        visit edit_album_track_path(album_one, track_two)

        expect do
          fill_in 'Title', with: 'Updated Track'
          fill_in 'Length in seconds', with: 200
          click_on 'Update Track'
        end.not_to change(Track, :count)

        track_two.reload
        expect(track_two).to have_attributes(title: 'Updated Track', length_in_seconds: 200)
        expect(page).to have_current_path(album_track_path(album_one, track_two), ignore_query: true)
        expect(page).to have_css('.alert-success', exact_text: 'Track was successfully updated.')
      end

      scenario 'Viewing the edit album_two track form page' do
        visit edit_album_track_path(album_two, track_three)

        aggregate_failures do
          expect(page).to have_css('h1', exact_text: "Edit Track for #{album_two.title}")
          expect(page).to have_field('Title', with: track_three.title)
          expect(page).to have_field('Length in seconds', with: track_three.length_in_seconds)
          expect(page).to have_button('Update Track')
          expect(page).to have_link('Back')
        end
      end

      scenario 'Updating a album_two track with valid details' do
        visit edit_album_track_path(album_two, track_three)

        expect do
          fill_in 'Title', with: 'Updated Track'
          fill_in 'Length in seconds', with: 200
          click_on 'Update Track'
        end.not_to change(Track, :count)

        track_three.reload
        expect(track_three).to have_attributes(title: 'Updated Track', length_in_seconds: 200)
        expect(page).to have_current_path(album_track_path(album_two, track_three), ignore_query: true)
        expect(page).to have_css('.alert-success', exact_text: 'Track was successfully updated.')
      end

      scenario 'Updating a track with missing title', :js do
        visit edit_album_track_path(album_one, track_one)

        expect do
          fill_in 'Title', with: ''
          click_on 'Update Track'
        end.not_to change(Track, :count)

        track_one.reload
        expect(track_one.title).to eq('360') # Track should not be updated
        message = page.find_by_id('track_title').native.attribute('validationMessage')
        expect(message).to match(/Please fill (out|in) this field\./)
      end

      scenario 'Updating a track with invalid length' do
        visit edit_album_track_path(album_one, track_one)

        expect do
          fill_in 'Length in seconds', with: 0
          click_on 'Update Track'
        end.not_to change(Track, :count)

        track_one.reload
        expect(track_one.length_in_seconds).to eq(133) # Track should not be updated
        expect(page).to have_css('.alert-danger', exact_text: 'Error! Unable to update track.')
        expect(page).to have_content('Length in seconds must be greater than 0', normalize_ws: true)
      end

      scenario 'Navigating to a track edit page from the album_one index page' do
        visit album_tracks_path(album_one)

        click_on 'Edit', match: :first

        expect(page).to have_current_path(edit_album_track_path(album_one, track_one), ignore_query: true)
      end

      scenario 'Navigating back to the album_one track index page from the edit page' do
        visit edit_album_track_path(album_one, track_two)

        click_on 'Back'

        expect(page).to have_current_path(album_tracks_path(album_one), ignore_query: true)
      end

      scenario 'Navigating to a track edit page from the album_two index page' do
        visit album_tracks_path(album_two)

        click_on 'Edit', match: :first

        expect(page).to have_current_path(edit_album_track_path(album_two, track_three), ignore_query: true)
      end

      scenario 'Navigating back to the track index page from the edit page' do
        visit edit_album_track_path(album_two, track_three)

        click_on 'Back'

        expect(page).to have_current_path(album_tracks_path(album_two), ignore_query: true)
      end

      scenario 'Navigating to the track edit page using unrelated album and track ids' do
        expect { visit edit_album_track_path(album_one, track_three) }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    feature 'Destroy Track' do
      scenario 'Deleting a album_one track from the index page' do
        visit album_tracks_path(album_one)

        expect(page).to have_content(track_one.title)
        expect do
          click_on 'Delete', match: :first
        end.to change(Track, :count).by(-1)

        expect(page).to have_current_path(album_tracks_path(album_one), ignore_query: true)
        expect(page).to have_css('.alert-success', exact_text: 'Track was successfully destroyed.')
        expect(page).to have_no_content(track_one.title)
      end
    end
  end
end
