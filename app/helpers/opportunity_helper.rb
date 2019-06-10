module OpportunityHelper
  def opportunity_status_link(string)
    case string
    when 'publish' then 'Published'
    when 'trash' then 'Trashed'
    when 'pending' then 'Pending'
    when 'draft' then 'Draft'
    else
      string.to_s.titleize
    end
  end

  def filtered_admin_opportunities_path
    admin_opportunities_path(session[:opportunity_filters])
  end
end
