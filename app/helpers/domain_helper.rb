module DomainHelper
  def is_bgs_site?(title_only = false)
    if Figaro.env.DOMAIN == Figaro.env.BGS_SITE_DOMAIN 
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
