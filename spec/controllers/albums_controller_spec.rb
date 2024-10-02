# frozen_string_literal: true

require 'rails_helper'
require 'rubocop'

RSpec.describe AlbumsController do
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
      get :index
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let!(:album) { create(:album) }

    it 'returns a success response' do
      get :show, params: { id: album }
      expect(response).to be_successful
    end

    it 'renders the show template' do
      get :show, params: { id: album }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let!(:album) { create(:album) }

    it 'returns a success response' do
      get :edit, params: { id: album }
      expect(response).to be_successful
    end

    it 'renders the edit template' do
      get :edit, params: { id: album }
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Album' do
        expect do
          post :create, params: { album: attributes_for(:album) }
        end.to change(Album, :count).by(1)
      end

      it 'redirects to the created album' do
        post :create, params: { album: attributes_for(:album) }
        expect(response).to redirect_to(albums_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Track' do
        expect do
          post :create, params: { album: attributes_for(:album, title: nil) }
        end.not_to change(Track, :count)
      end

      it 're-renders the new template' do
        post :create, params: { album: attributes_for(:album, title: nil) }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:album) { create(:album) }

    context 'with valid parameters' do
      it 'updates the requested album' do
        patch :update, params: { id: album, album: { title: 'New Title' } }
        album.reload
        expect(album.title).to eq('New Title')
      end

      it 'redirects to the album' do
        patch :update, params: { id: album, album: attributes_for(:album) }
        expect(response).to redirect_to(album)
      end
    end

    context 'with invalid parameters' do
      it 'does not update the album' do
        original_title = album.title
        patch :update, params: { id: album, album: { title: nil } }
        album.reload
        expect(album.title).to eq(original_title)
      end

      it 're-renders the edit template' do
        patch :update, params: { id: album, album: { title: nil } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:album) { create(:album) }

    it 'destroys the requested track' do
      expect do
        delete :destroy, params: { id: album }
      end.to change(Album, :count).by(-1)
    end

    it 'redirects to the albums list' do
      delete :destroy, params: { id: album }
      expect(response).to redirect_to(albums_url)
    end
  end
end
