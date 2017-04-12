require 'rails_helper'

RSpec.describe StatsPolicy do
  subject { StatsPolicy.new(current_editor, nil) }

  context 'for uploaders' do
    let(:current_editor) { create(:uploader) }
    it { is_expected.to permit_action(:index) }
  end

  context 'for publishers' do
    let(:current_editor) { create(:publisher) }
    it { is_expected.to permit_action(:index) }
  end

  context 'for admins' do
    let(:current_editor) { create(:admin) }
    it { is_expected.to permit_action(:index) }
  end
end
