require 'rails_helper'
require 'pundit/matchers'

RSpec.describe OpportunityPolicy do
  subject { OpportunityPolicy.new(editor, opportunity) }

  let(:resolved_scope) do
    OpportunityPolicy::Scope.new(editor, Opportunity.all).resolve
  end

  context 'for administrators' do
    let(:editor) { create(:editor, role: :administrator) }
    let(:opportunity) { create(:opportunity) }

    it 'includes others’ opportunities in the scope' do
      expect(resolved_scope).to include(opportunity)
    end

    context 'editing' do
      it { is_expected.to permit_action(:edit) }
    end

    context 'trashing' do
      it { is_expected.to permit_action(:trash) }
    end

    context 'restoring' do
      let(:opportunity) { create(:opportunity, status: :trash) }
      it { is_expected.to permit_action(:restore) }
    end

    context 'publishing' do
      let(:opportunity) { create(:opportunity, status: :pending) }
      it { is_expected.to permit_action(:publishing) }
    end
  end

  context 'for uploaders' do
    let(:editor) { create(:editor, role: :uploader, service_provider: create(:service_provider)) }

    context 'viewing and creating opportunities' do
      let(:opportunity) { create(:opportunity) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
    end

    context 'respecting their own opportunities' do
      context 'when not published' do
        let(:opportunity) { create(:opportunity, status: :pending, author: editor) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:update) }
      end

      context 'when published' do
        let(:opportunity) { create(:opportunity, status: :publish, author: editor) }
        it { is_expected.not_to permit_action(:edit) }
        it { is_expected.not_to permit_action(:update) }
      end
    end

    context 'respecting others’ opportunities' do
      context 'when published' do
        let(:opportunity) do
          other_editor = create(:editor, email: 'colleague@dit.gov.uk')
          create(:opportunity, :published, author: other_editor)
        end

        it 'includes these in the scope' do
          expect(resolved_scope).to include(opportunity)
        end

        it { is_expected.to permit_action(:show) }
        it { is_expected.not_to permit_action(:edit) }
        it { is_expected.not_to permit_action(:update) }
      end

      context 'when not published' do
        let(:opportunity) do
          other_editor = create(:editor, email: 'colleague@dit.gov.uk')
          create(:opportunity, author: other_editor, status: :pending)
        end

        it 'does not include these in the scope' do
          expect(resolved_scope).not_to include(opportunity)
        end

        it { is_expected.not_to permit_action(:show) }
        it { is_expected.not_to permit_action(:edit) }
        it { is_expected.not_to permit_action(:update) }

        context 'but associated with the current editor’s service provider' do
          let!(:editor) { create(:editor, service_provider: create(:service_provider)) }
          let(:opportunity) { create(:opportunity, service_provider: editor.service_provider) }

          it 'includes these in the scope' do
            expect(resolved_scope).to include(opportunity)
          end

          it { is_expected.to permit_action(:show) }

          context 'when both the editor’s and the opportunity’s S.P. are nil' do
            let(:editor) { create(:editor, service_provider: nil) }
            let(:opportunity) do
              opportunity = build(:opportunity, service_provider: nil)
              opportunity.save(validate: false)
              opportunity
            end

            it 'does not include these in the scope' do
              expect(resolved_scope).not_to include(opportunity)
            end

            it { is_expected.not_to permit_action(:show) }
          end
        end
      end
    end
  end
end
