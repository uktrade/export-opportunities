require 'rails_helper'

describe Admin::EditorsController, type: :controller do
  describe '#index' do
    context 'as an admin' do
      login_editor(role: :admin)

      it 'returns 200' do
        get :index
        expect(response.status).to eq 200
      end

      it 'assigns editors ' do
        editors = create(:editor)

        get :index
        expect(assigns(:editors)).to include(editors)
      end
    end

    context 'as a publisher' do
      login_editor(role: :publisher)

      it 'returns 404' do
        get :index
        expect(response.status).to eq 404
      end
    end

    context 'as an uploader' do
      login_editor(role: :uploader)

      it 'returns 404' do
        get :index
        expect(response.status).to eq 404
      end
    end
  end

  describe '#show' do
    login_editor(role: :admin)

    it 'returns 200' do
      editor = create(:editor)

      get :show, id: editor.id
      expect(response.status).to eq 200
    end

    context 'when the editor does not exist' do
      login_editor(role: :admin)

      it 'returns 404' do
        get :show, id: 'foo'
        expect(response.status).to eq 404
      end
    end
  end

  describe '#edit' do
    login_editor(role: :admin)

    it 'returns 200' do
      editor = create(:editor)

      get :edit, id: editor.id
      expect(response.status).to eq 200
    end

    it 'assigns the editor' do
      editor = create(:editor)

      get :edit, id: editor.id
      expect(assigns(:editor)).to eq(editor)
    end
  end

  describe '#update' do
    login_editor(role: :admin)

    it 'updates the editor’s role' do
      editor = create(:uploader)

      put :update, id: editor.id, editor: { role: 'publisher' }
      editor.reload
      expect(editor.role).to eq 'publisher'
    end

    it 'assigns the editor' do
      editor = create(:uploader)

      put :update, id: editor.id, editor: { role: 'publisher' }
      editor.reload
      expect(assigns(:editor)).to eq(editor)
    end

    it 'redirects to the editor page' do
      editor = create(:uploader)

      put :update, id: editor.id, editor: { role: 'publisher' }
      expect(response).to redirect_to(admin_editor_path(editor))
    end
  end
end
