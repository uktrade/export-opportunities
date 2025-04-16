module DomainHelper
  def bgs_site?
    Figaro.env.DOMAIN == Figaro.env.BGS_SITE
  end

  def fetch_domain(title_only = false)
    if bgs_site?
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
