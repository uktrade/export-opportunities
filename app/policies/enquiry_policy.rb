class EnquiryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    editor_is_admin_or_publisher_or_previewer? || editor_is_opportunity_author? || editor_is_in_opportunity_service_provider?
  end

  def editor_is_opportunity_author?
    @record.opportunity.author == @editor
  end

  def editor_is_in_opportunity_service_provider?
    return false if @editor.service_provider.blank?

    @record.opportunity.service_provider == @editor.service_provider
  end

  class Scope
    attr_reader :editor, :scope

    def initialize(editor, scope)
      @editor = editor
      @scope = scope
    end

    def resolve
      if %w[administrator previewer publisher].include? editor.role
        scope.all
      else
        scope.joins(:opportunity)
          .where(opportunities: { author_id: editor.id })
          .union(
            scope.joins(:opportunity)
              .where(opportunities: { service_provider_id: editor.service_provider&.id })
              .where('opportunities.service_provider_id IS NOT NULL')
          )
      end
    end
  end
end
