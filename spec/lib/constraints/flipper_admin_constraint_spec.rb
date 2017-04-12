require 'rails_helper'
require 'constraints/flipper_admin_constraint'

RSpec.describe FlipperAdminConstraint do
  it 'matches when the user is signed on a whitelisted email' do
    allow(Figaro.env).to receive(:flipper_whitelist!) { 'developer@dxw.com' }
    user = create(:user, email: 'developer@dxw.com')

    request = ActionDispatch::TestRequest.new('warden' => double(user: user))

    constraint = FlipperAdminConstraint.new
    expect(constraint.matches?(request)).to be true
  end

  it 'supports a whitelist of multiple emails' do
    allow(Figaro.env).to receive(:flipper_whitelist!) { 'developer@dxw.com,administrator@dit.gov,minister@dit.gov' }
    user = create(:user, email: 'administrator@dit.gov')

    request = ActionDispatch::TestRequest.new('warden' => double(user: user))

    constraint = FlipperAdminConstraint.new
    expect(constraint.matches?(request)).to be true
  end

  it 'ignores whitespace' do
    allow(Figaro.env).to receive(:flipper_whitelist!) { '  developer@dxw.com ' }
    user = create(:user, email: 'developer@dxw.com')

    request = ActionDispatch::TestRequest.new('warden' => double(user: user))

    constraint = FlipperAdminConstraint.new
    expect(constraint.matches?(request)).to be true
  end

  it 'does not match when the user is signed in on a non-whitelisted email' do
    allow(Figaro.env).to receive(:flipper_whitelist!) { 'developer@dxw.com' }
    user = create(:user, email: 'uploader@dit.gov')

    request = ActionDispatch::TestRequest.new('warden' => double(user: user))

    constraint = FlipperAdminConstraint.new
    expect(constraint.matches?(request)).to be false
  end

  it 'does not match when the user is not signed in' do
    request = ActionDispatch::TestRequest.new('warden' => double(user: nil))

    constraint = FlipperAdminConstraint.new
    expect(constraint.matches?(request)).to be false
  end
end
