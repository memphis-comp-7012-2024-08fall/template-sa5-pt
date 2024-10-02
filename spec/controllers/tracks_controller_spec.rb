# frozen_string_literal: true

require 'rails_helper'
require 'rubocop'

RSpec.describe TracksController do
  let(:album) { create(:album) }

  it 'has no nested method definitions' do
    result = RuboCop::CLI.new.run(['--only', 'Style/NestedMethodDefinition', 'app/controllers'])
    expect(result).to eq(0), 'Rubocop detected nested method definitions in controllers.'
  end

  it 'defines required actions' do
    expect(described_class.instance_methods(false)).to match_array %i[index show new edit create update
                                                                      destroy]
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { album_id: album }
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index, params: { album_id: album }
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let!(:track) { create(:track) }

    it 'returns a success response' do
      get :show, params: { id: track, album_id: track.album }
      expect(response).to be_successful
    end

    it 'renders the show template' do
      get :show, params: { id: track, album_id: track.album }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: { album_id: album }
      expect(response).to be_successful
    end

    it 'renders the new template' do
      get :new, params: { album_id: album }
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let!(:track) { create(:track) }

    it 'returns a success response' do
      get :edit, params: { id: track, album_id: track.album }
      expect(response).to be_successful
    end

    it 'renders the edit template' do
      get :edit, params: { id: track, album_id: track.album }
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Track' do
        expect do
          post :create, params: { track: attributes_for(:track), album_id: album }
        end.to change(Track, :count).by(1)
      end

      it 'redirects to the created track' do
        post :create, params: { track: attributes_for(:track), album_id: album }
        expect(response).to redirect_to(album_tracks_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Track' do
        expect do
          post :create, params: { track: attributes_for(:track, title: nil), album_id: album }
        end.not_to change(Track, :count)
      end

      it 're-renders the new template' do
        post :create, params: { track: attributes_for(:track, title: nil), album_id: album }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:track) { create(:track, album:) }

    context 'with valid parameters' do
      it 'updates the requested track' do
        patch :update, params: { id: track, track: { title: 'New Title' }, album_id: album }
        track.reload
        expect(track.title).to eq('New Title')
      end

      it 'redirects to the track' do
        patch :update, params: { id: track, track: attributes_for(:track), album_id: album }
        expect(response).to redirect_to(album_track_url(album, track))
      end
    end

    context 'with invalid parameters' do
      it 'does not update the track' do
        original_title = track.title
        patch :update, params: { id: track, track: { title: nil }, album_id: album }
        track.reload
        expect(track.title).to eq(original_title)
      end

      it 're-renders the edit template' do
        patch :update, params: { id: track, track: { title: nil }, album_id: album }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:track) { create(:track) }

    it 'destroys the requested track' do
      expect do
        delete :destroy, params: { id: track, album_id: track.album }
      end.to change(Track, :count).by(-1)
    end

    it 'redirects to the tracks list' do
      delete :destroy, params: { id: track, album_id: track.album }
      expect(response).to redirect_to(album_tracks_url)
    end
  end
end
