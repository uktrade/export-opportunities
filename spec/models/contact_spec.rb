require 'rails_helper'

describe Contact, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }

    it 'accepts valid email addresses' do
      expect(Contact.new(email: 'foo@bar.com')).to have(0).errors_on(:email)
    end

    it 'accepts mixed-case email addresses' do
      expect(Contact.new(email: 'Foo@bAr.com')).to have(0).errors_on(:email)
    end

    it 'rejects invalid email addresses' do
      expect(Contact.new(email: 'foo.bar.com')).to have(1).error_on(:email)
    end

    it 'accepts email addresses with trailing whitespace' do
      expect(Contact.new(email: 'foo@bar.com ')).to have(0).errors_on(:email)
    end

    it 'accepts email addresses with leading whitespace' do
      expect(Contact.new(email: ' foo@bar.com')).to have(0).errors_on(:email)
    end
  end

  describe 'sanitisation' do
    it 'strips whitespace around emails before saving' do
      contact = create(:contact, email: " foo@bar.com \t")
      expect(contact.email).to eq 'foo@bar.com'
    end

    it 'downcases emails before saving' do
      contact = create(:contact, email: 'Foo@bAr.com')
      expect(contact.email).to eq 'foo@bar.com'
    end
  end
end
