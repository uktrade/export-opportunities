module DomainHelper
  def fetch_domain(title_only = false)
    if Figaro.env.DOMAIN == Figaro.env.BGS_SITE
      if title_only
        "Business"
      else
        "business.gov.uk"
      end
    else
      if title_only
        "Great"
      else
        "great.gov.uk"
      end
    end
  end
end
