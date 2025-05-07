# frozen_string_literal: true

# Helper module for domain-related functionality
module DomainHelper
  HOTFIX_DOMAIN = 'www.hotfix.bgs.uktrade.digital'

  def bgs_site?
    Figaro.env.DOMAIN == Figaro.env.BGS_SITE
  end

  def fetch_domain(title_only: false)
    if bgs_site? && Figaro.env.DOMAIN == HOTFIX_DOMAIN
      return 'hotfix.bgs.uktrade.digital'
    end

    domains = {
      bgs: { title: 'Business', domain: 'business.gov.uk' },
      great: { title: 'Great', domain: 'great.gov.uk' }
    }

    site_key = bgs_site? ? :bgs : :great
    title_only ? domains[site_key][:title] : domains[site_key][:domain]
  end
end
