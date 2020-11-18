class AdminOpportunityPresenter < OpportunityPresenter
  def initialize(view_context, opportunity, content)
    super(view_context, opportunity, content)
  end

  def edit_button
    if @view_context.policy(@opportunity).edit?
      @view_context.link_to 'Edit opportunity', edit_admin_opportunity_path(@opportunity), class: 'button'
    else
      ''
    end
  end

  def publishing_button
    case @opportunity.status
    when 'publish'
      button_to('Unpublish', :patch, 'pending') if @view_context.policy(@opportunity).publishing?
    when 'pending'
      button_to('Publish', :patch, 'publish') if @view_context.policy(@opportunity).publishing?
    when 'trash'
      button_to('Restore', :patch, 'pending') if @view_context.policy(@opportunity).restore?
    else
      ''
    end
  end

  def trash_button
    if @view_context.policy(@opportunity).trash?
      button_to('Trash', :delete)
    else
      ''
    end
  end

  def draft_button
    case @opportunity.status
    when 'trash', 'pending'
      button_to('Draft', :patch, 'draft') if @view_context.policy(opportunity).draft?
    else
      ''
    end
  end

  def pending_button
    if @opportunity.status == 'draft' && @view_context.policy(opportunity).uploader_previewer_restore?
      button_to('Pending', :patch, 'pending')
    else
      ''
    end
  end

  def button_to(text, method, status = '')
    params = { status: status } if status.present?
    button = view_context.button_to(text,
                                    admin_opportunity_status_path(@opportunity),
                                    method: method,
                                    params: params,
                                    class: 'button')
    button.class == ActiveSupport::SafeBuffer ? button : ''
  end

  # Third party opps (at least in development)
  # do not have an author, so throw an error.
  def author
    if @opportunity.author.present?
      @opportunity.author.name
    else
      'editor'
    end
  end
end
