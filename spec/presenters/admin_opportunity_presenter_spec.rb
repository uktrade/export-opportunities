# coding: utf-8

require 'rails_helper'

RSpec.describe AdminOpportunityPresenter do
  let(:editor) { create(:editor, role: :administrator) }
  let(:view_context) { admin_view_context(editor) }
  let(:paths) { Rails.application.routes.url_helpers }

  describe '#edit_button' do
    it 'returns html for an Edit button' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.edit_button

      expect(has_html?(button)).to be_truthy
      expect(button).to include('Edit opportunity')
      expect(button).to include(paths.edit_admin_opportunity_path(opportunity))
    end
  end

  describe '#publishing_button' do
    it 'returns html for an Publishing button when status is publish' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :publish)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.publishing_button

      expect(has_html?(button)).to be_truthy
      expect(button).to include('Unpublish')
      expect(button).to include(paths.admin_opportunity_status_path(opportunity))
    end

    it 'returns html for an Publishing button when status is pending' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :pending)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.publishing_button

      expect(has_html?(button)).to be_truthy
      expect(button).to include('Publish')
      expect(button).to include(paths.admin_opportunity_status_path(opportunity))
    end

    it 'returns html for an Publishing button when status is trash' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :trash)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.publishing_button

      expect(has_html?(button)).to be_truthy
      expect(button).to include('Restore')
      expect(button).to include(paths.admin_opportunity_status_path(opportunity))
    end

    it 'returns empty string when status is not publish, pending, or trash' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :draft)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.publishing_button

      expect(button).to eq('')
    end
  end

  describe '#trash_button' do
    it 'returns html for a Trash button' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :draft)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.trash_button

      expect(has_html?(button)).to be_truthy
      expect(button).to include('Trash')
      expect(button).to include(paths.admin_opportunity_status_path(opportunity))
    end
  end

  describe '#draft_button' do
    it 'returns html for a Draft button when statis is trash' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :trash)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.draft_button

      expect(has_html?(button)).to be_truthy
      expect(button).to include('Draft')
      expect(button).to include(paths.admin_opportunity_status_path(opportunity))
    end

    it 'returns html for a Draft button when status is pending' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :pending)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.draft_button

      expect(has_html?(button)).to be_truthy
      expect(button).to include('Draft')
      expect(button).to include(paths.admin_opportunity_status_path(opportunity))
    end


    it 'returns blank string when status is neither trash or pending' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :draft)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.draft_button

      expect(button).to eq('')
    end
  end

  describe '#pending_button' do
    it 'returns html for a Pending button when status is draft' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :draft)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.pending_button

      expect(has_html?(button)).to be_truthy
      expect(button).to include('Pending')
      expect(button).to include(paths.admin_opportunity_status_path(opportunity))
    end

    it 'returns empty string when status is not draft' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :pending)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.pending_button

      expect(button).to eq('')
    end
  end

  describe '#button_to' do
    it 'returns html for a button' do
      content = get_content('admin/opportunities')
      opportunity = create(:opportunity, status: :draft)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)
      button = presenter.button_to('some text', 'get', 'status_x')

      expect(has_html?(button)).to be_truthy
      expect(button).to include('some text')
      expect(button).to include('get')
      expect(button).to include('status_x')
      expect(button).to include(paths.admin_opportunity_status_path(opportunity))
    end
  end

  describe '#author' do
    it 'returns author name or \'editor\' when author is nil' do
      content = get_content('admin/opportunities')
      author = create(:editor, name: 'Fred')
      opportunity = create(:opportunity, author: author)
      presenter = AdminOpportunityPresenter.new(view_context, opportunity, content)

      expect(presenter.author).to eq('Fred')

      opportunity.author = nil # now remove it
      expect(presenter.author).to eq('editor')
    end
  end

  # Helpers

  def has_html?(str)
    /\<\/\w+\>/.match(str)
  end

  def admin_view_context(editor)
    TestAdminOpportunitiesController.new(editor).view_context
  end

  class TestAdminOpportunitiesController < Admin::OpportunitiesController
    def initialize(editor)
      @editor = editor
    end

    def pundit_user
      @editor
    end
  end
end
