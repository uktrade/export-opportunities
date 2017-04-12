require 'rails_helper'
require 'shared/shared_examples_for_passwords'

RSpec.describe Editor do
  before do
    stub_blacklist_loader
  end

  it_behaves_like 'has complex password'
  it_behaves_like 'has long password'

  it { is_expected.to belong_to :service_provider }

  context 'when the record is not persisted' do
    subject { Editor.new }
    it { is_expected.to validate_presence_of :password }
  end

  context 'when the record is persisted' do
    subject(:persisted_editor) { create(:editor) }
    it "doesn't require a password" do
      persisted_editor.password = nil
      persisted_editor.password_confirmation = nil
      expect(persisted_editor).to be_valid
    end
  end
end
