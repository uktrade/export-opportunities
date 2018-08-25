class NewDomainConstraint
  def matches?(request)
    request.host != ENV.fetch('legacy_domain')
  end
end
