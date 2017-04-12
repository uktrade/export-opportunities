require 'rails_helper'

RSpec.describe EditorPolicy do
  subject { EditorPolicy.new(current_editor, editor_record) }
  let(:editor_record) { create(:editor) }

  context 'for uploaders' do
    let(:current_editor) { create(:uploader) }

    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
  end

  context 'for publishers' do
    let(:current_editor) { create(:publisher) }

    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
  end

  context 'for admins' do
    let(:current_editor) { create(:admin) }

    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
  end
end
