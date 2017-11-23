require 'rails_helper'

describe Admin::RegistrationsController, type: :controller do
  describe '#new' do
    context 'as an admin' do
      login_editor(role: :admin)

      it 'returns 200' do
        get :new
        expect(response.status).to eq 200
      end
    end

    context 'as an uploader' do
      login_editor(role: :uploader)

      it 'returns 404' do
        get :new
        expect(response.status).to eq 404
      end
    end

    context 'as an publisher' do
      login_editor(role: :publisher)

      it 'returns 404' do
        get :new
        expect(response.status).to eq 404
      end
    end
  end

  describe '#create' do
    context 'as an admin' do
      login_editor(role: :admin)

      it "doesn't return a 302" do
        post :create, {}
        expect(response.status).not_to eq 302
      end

      %w[uploader publisher administrator].each do |role|
        it 'assigns the role #{role}' do
          post :create, editor: { email: "#{SecureRandom.hex}@example.com", name: 'Mx A Smith', role: role }
          expect(Editor.last.role).to eq role
        end
      end
    end

    context 'as an uploader' do
      login_editor(role: :uploader)

      it 'returns 404' do
        post :create, {}
        expect(response.status).to eq 404
      end
    end

    context 'as a publisher' do
      login_editor(role: :publisher)

      it 'returns 404' do
        post :create, {}
        expect(response.status).to eq 404
      end
    end
  end

  describe '#destroy' do
    login_editor(role: :admin)
    it 'removes the editor' do
      travel(0.seconds) do
        editor = create(:editor)

        delete :destroy, id: editor.id

        expect(editor.reload.deactivated_at).to eq Time.current
      end
    end

    it 'returns 404 when the editor does not exist' do
      delete :destroy, id: 'foobar'

      expect(response.status).to eq 404
    end
  end
end
