require 'rails_helper'
require 'constraints/new_domain_constraint'

RSpec.describe NewDomainConstraint do
  it 'does not match the domain specified in LEGACY_DOMAIN' do
    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(:legacy_domain!).and_return('exportingisgreat.gov.uk')
    request = ActionDispatch::TestRequest.new('HTTP_HOST' => 'exportingisgreat.gov.uk')

    constraint = NewDomainConstraint.new
    expect(constraint.matches?(request)).to be false
  end
end
