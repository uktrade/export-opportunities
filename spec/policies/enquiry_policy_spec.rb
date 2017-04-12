require 'rails_helper'

RSpec.describe EnquiryPolicy do
  subject { EnquiryPolicy.new(editor, enquiry) }

  let(:resolved_scope) do
    EnquiryPolicy::Scope.new(editor, Enquiry.all).resolve
  end

  context 'for publishers and admins' do
    let(:editor) { create(:publisher) }
    let(:enquiry) { create(:enquiry) }

    it { is_expected.to permit_action(:show) }
  end

  context 'for uploaders' do
    let(:editor) { create(:uploader, service_provider: create(:service_provider)) }
    let(:enquiry) { create(:enquiry) }

    it { is_expected.not_to permit_action(:show) }

    it 'does not include others’ enquiries in the scope' do
      expect(resolved_scope).not_to include enquiry
    end

    context 'for enquiries on their own opportunities' do
      let(:enquiry) do
        opportunity = create(:opportunity, author: editor)
        create(:enquiry, opportunity: opportunity)
      end

      it 'includes these in the scope' do
        expect(resolved_scope).to include enquiry
      end

      it { is_expected.to permit_action(:show) }
    end

    context 'for enquiries on opportunities in their own service provider' do
      let!(:editor) { create(:editor, service_provider: create(:service_provider)) }
      let(:enquiry) do
        opportunity = create(:opportunity, service_provider: editor.service_provider)
        create(:enquiry, opportunity: opportunity)
      end

      it 'includes these in the scope' do
        expect(resolved_scope).to include enquiry
      end

      it { is_expected.to permit_action(:show) }

      context 'when both the editor’s and the opportunity’s S.P. are nil' do
        let(:enquiry) do
          opportunity = build(:opportunity, service_provider: nil)
          opportunity.save(validate: false)
          create(:enquiry, opportunity: opportunity)
        end

        let(:editor) { create(:editor, service_provider: nil) }

        it 'does not include these in the scope' do
          expect(resolved_scope).not_to include(enquiry)
        end

        it { is_expected.not_to permit_action(:show) }
      end
    end
  end
end
