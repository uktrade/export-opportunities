shared_examples_for 'has long password' do
  let(:resource) { described_class.new }

  it 'is invalid when the password is under 10 characters' do
    resource.password = 'abcdefg'
    expect(resource).to have(1).error_on(:password)
  end

  it 'is valid when the password has exactly 10 characters' do
    resource.password = 'abcdefghij'
    expect(resource).to have(0).errors_on(:password)
  end

  it 'is valid when the password has over 10 characters' do
    resource.password = 'abcdefghijklmnop'
    expect(resource).to have(0).errors_on(:password)
  end
end

shared_examples_for 'has complex password' do
  let(:resource) { described_class.new }

  it 'is valid for strong passwords' do
    resource.password = 'mouse-trap-cheese-test'
    expect(resource).to have(0).errors_on(:password)
  end

  it 'is invalid for passwords that match banned patterns' do
    aggregate_failures do
      %w(password987654321 ilovedxwyeah 12345678901).each do |password|
        resource.password = password
        expect(resource).to have(1).error_on(:password),
          "expected #{password} to be invalid but it was valid"
      end
    end
  end

  it 'loads in a password blacklist from a file' do
    blacklist = %w(a_bad_passw0rd another_b4d_1)

    stub_blacklist_loader(blacklist)

    aggregate_failures do
      blacklist.each do |password|
        resource.password = password
        expect(resource).to have(1).error_on(:password),
          "expected #{password} to be invalid but it was valid"
      end
    end
  end

  it 'ignores case when checking patterns' do
    aggregate_failures do
      %w(Password987654321 iLoveDXWyEAH!).each do |password|
        resource.password = password
        expect(resource).to have(1).error_on(:password),
          "expected #{password} to be invalid but it was valid"
      end
    end
  end

  it 'ignores case when checking banned_passwords' do
    blacklist = %w(a_bad_passw0rd AnOther_b4d_1)

    stub_blacklist_loader(blacklist)

    aggregate_failures do
      %w(a_BAD_pAssw0rd another_b4d_1).each do |password|
        resource.password = password
        expect(resource).to have(1).error_on(:password),
          "expected #{password} to be invalid but it was valid"
      end
    end
  end
end

# required for any model which uses the StrongPasswordValidator:
def stub_blacklist_loader(result = [])
  fake_blacklist_loader = instance_double('PasswordBlacklistLoader')
  allow(fake_blacklist_loader).to receive(:load_passwords).and_return result
  allow(PasswordBlacklistLoader).to receive(:new).and_return fake_blacklist_loader
end
