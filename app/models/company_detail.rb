class CompanyDetail
  attr_accessor :name, :number, :postcode

  def initialize(args = {})
    args = ActiveSupport::HashWithIndifferentAccess.new args
    @name = args.dig('title')
    @number = args.dig('company_number')
    @postcode = args.dig('address', 'postal_code')
  end
end
