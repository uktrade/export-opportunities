require 'rails_helper'
require 'shared/shared_examples_for_passwords'

RSpec.describe User do
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to have_many :subscriptions }

  context 'validations' do
    it 'is valid with a duplicate email address' do
      create(:user, email: 'dupe@example.net', uid: '123')

      expect { create(:user, email: 'dupe@example.net', uid: '456') }.not_to raise_error

      expect(User.where(email: 'dupe@example.net').count).to eql 2
    end

    context 'with a duplicate uid/provider' do
      it 'is invalid' do
        create(:user, uid: '123', provider: 'exporting_is_great', email: 'email@example.com')
        new_user = build(:user, uid: '123', provider: 'exporting_is_great', email: 'another@example.com')

        expect(new_user).not_to be_valid
      end

      it 'is however valid when uid/provider are both nil' do
        create(:user, uid: nil, provider: nil, email: 'email@example.com')
        new_user = build(:user, uid: nil, provider: nil, email: 'another@example.com')

        expect(new_user).to be_valid
      end
    end
  end

  describe '#saved_enquiry_data?' do
    it 'returns true when the user has data to prepopulate an enquiry form' do
      user = create(:user)
      create(:enquiry, user: user)

      expect(user.saved_enquiry_data?).to be true
    end

    it 'returns false when the user has no such data' do
      user = create(:user)

      expect(user.saved_enquiry_data?).to be false
    end
  end

  describe '.from_omniauth' do
    it 'creates a new user with credentials from the auth hash' do
      info = double(:info, email: 'test@example.com')
      auth = double(:auth, uid: '1234', provider: 'exporting_is_great', info: info)

      expect { User.from_omniauth(auth) }.to change { User.count }.by(1)

      new_user = User.first
      expect(new_user.uid).to eql '1234'
      expect(new_user.provider).to eql 'exporting_is_great'
      expect(new_user.email).to eql 'test@example.com'
    end

    context 'when a user with the same email address exists' do
      it 'creates a new user with credentials from the auth hash' do
        create(:user, email: 'dupe@example.com', uid: '1234', provider: 'exporting_is_great')

        info = double(:info, email: 'dupe@example.com')
        auth = double(:auth, uid: '5678', provider: 'exporting_is_great', info: info)

        new_user = User.from_omniauth(auth)

        expect(User.where(email: 'dupe@example.com').count).to eql 2

        expect(new_user.uid).to eql '5678'
        expect(new_user.provider).to eql 'exporting_is_great'
        expect(new_user.email).to eql 'dupe@example.com'
      end
    end

    context 'when a stub user with the same email address exists' do
      it 'updates the stub user with credentials from the auth hash' do
        create(:user, email: 'stub@example.com', uid: nil, provider: nil)

        info = double(:info, email: 'stub@example.com')
        auth = double(:auth, uid: '5678', provider: 'exporting_is_great', info: info)

        expect { User.from_omniauth(auth) }.not_to change { User.count }

        new_user = User.find_by(email: 'stub@example.com')
        expect(new_user.uid).to eql '5678'
        expect(new_user.provider).to eql 'exporting_is_great'
        expect(new_user.email).to eql 'stub@example.com'
      end

      context 'when SSO sends us a user with the same address, differently cased' do
        it 'coerces the SSO email to lower-case and does not create a new user' do
          create(:user, :stub, email: 'email@example.com')
          info = double(:info, email: 'emAiL@ExaMpLE.cOM')
          auth = double(:auth, uid: '5678', provider: 'exporting_is_great', info: info)

          User.from_omniauth(auth)

          expect(User.where(email: 'email@example.com').count).to eql 1
        end
      end
    end

    context 'when a user with the same uid and provider exists, but a different email address' do
      it 'updates the user with the new email address' do
        create(:user, email: 'original@example.com', uid: '5678', provider: 'exporting_is_great')

        info = double(:info, email: 'new@example.com')
        auth = double(:auth, uid: '5678', provider: 'exporting_is_great', info: info)

        expect { User.from_omniauth(auth) }.not_to change { User.count }

        updated_user = User.find_by(uid: '5678', provider: 'exporting_is_great')
        expect(updated_user.email).to eql 'new@example.com'
      end
    end
  end
end
