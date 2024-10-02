# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routes follow resource naming' do
  context 'when routing' do
    specify 'Albums index' do
      expect(get: albums_path).to route_to 'albums#index'
    end

    specify 'Albums show' do
      expect(get: album_path(1)).to route_to controller: 'albums', action: 'show', id: '1'
    end

    specify 'Albums new' do
      expect(get: new_album_path).to route_to 'albums#new'
    end

    specify 'Albums create' do
      expect(post: albums_path).to route_to 'albums#create'
    end

    specify 'Albums edit' do
      expect(get: edit_album_path(1)).to route_to controller: 'albums', action: 'edit', id: '1'
    end

    specify 'Albums update' do
      expect(patch: album_path(1)).to route_to controller: 'albums', action: 'update', id: '1'
    end

    specify 'Albums destroy' do
      expect(delete: album_path(1)).to route_to controller: 'albums', action: 'destroy', id: '1'
    end

    specify 'Tracks index' do
      expect(get: album_tracks_path(1)).to route_to 'tracks#index', album_id: '1'
    end

    specify 'Tracks show' do
      expect(get: album_track_path(1, 2)).to route_to controller: 'tracks', action: 'show', album_id: '1', id: '2'
    end

    specify 'Tracks new' do
      expect(get: new_album_track_path(1)).to route_to 'tracks#new', album_id: '1'
    end

    specify 'Tracks create' do
      expect(post: album_tracks_path(1)).to route_to 'tracks#create', album_id: '1'
    end

    specify 'Tracks edit' do
      expect(get: edit_album_track_path(1, 2)).to route_to controller: 'tracks', action: 'edit', album_id: '1', id: '2'
    end

    specify 'Tracks update' do
      expect(patch: album_track_path(1, 2)).to route_to controller: 'tracks', action: 'update', album_id: '1', id: '2'
    end

    specify 'Tracks destroy' do
      expect(delete: album_track_path(1, 2)).to route_to controller: 'tracks', action: 'destroy', album_id: '1', id: '2'
    end
  end

  context 'when creating path helpers' do
    specify 'albums_path' do
      expect(albums_path).to eq '/albums'
    end

    specify 'album_path' do
      expect(album_path(1)).to eq '/albums/1'
    end

    specify 'new_album_path' do
      expect(new_album_path).to eq '/albums/new'
    end

    specify 'edit_album_path' do
      expect(edit_album_path(1)).to eq '/albums/1/edit'
    end

    specify 'album_tracks_path' do
      expect(album_tracks_path(1)).to eq '/albums/1/tracks'
    end

    specify 'album_track_path' do
      expect(album_track_path(1, 2)).to eq '/albums/1/tracks/2'
    end

    specify 'new_album_track_path' do
      expect(new_album_track_path(1)).to eq '/albums/1/tracks/new'
    end

    specify 'edit_album_track_path' do
      expect(edit_album_track_path(1, 2)).to eq '/albums/1/tracks/2/edit'
    end
  end
end
