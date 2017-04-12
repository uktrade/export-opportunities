class NewDomainConstraint
  def matches?(request)
    request.host != Figaro.env.legacy_domain!
  end
end
