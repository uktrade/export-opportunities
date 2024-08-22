require 'rails_helper'

RSpec.describe 'Trash an opportunity' do
  context 'when the editor is an admin' do
    it 'allows trashing opportunities' do
      login_as create(:admin)
      create(:opportunity, slug: 'unpublishable-opportunity', status: :pending)
      delete '/export-opportunities/admin/opportunities/unpublishable-opportunity/status/'

      expect(response.code).to redirect_to('/export-opportunities/admin/opportunities/unpublishable-opportunity/')
    end
  end

  context 'when the editor is a non-admin' do
    it 'disallows trashing opportunities' do
      uploader = create(:uploader)
      login_as uploader
      create(:opportunity, slug: 'unpublishable-opportunity', status: :pending, author: uploader)
      delete '/export-opportunities/admin/opportunities/unpublishable-opportunity/status/'

      expect(response.status).to eq 401
    end
    it 'disallows restoring trashed opportunities' do
      uploader = create(:uploader)
      login_as uploader
      create(:opportunity, slug: 'trashed-opportunity', status: :trash, author: uploader)
      patch '/export-opportunities/admin/opportunities/trashed-opportunity/status/', params: { status: 'pending' }

      expect(response.status).to eq 401
    end
  end

  context 'when the record is published' do
    it 'disallows trashing opportunities' do
      login_as create(:admin)
      create(:opportunity, slug: 'unpublishable-opportunity', status: :publish)
      delete '/export-opportunities/admin/opportunities/unpublishable-opportunity/status/'

      expect(response.status).to eq 401
    end
  end
end
