class User < ApplicationRecord
  include DeviseUserMethods

  if Figaro.env.bypass_sso?
    devise :rememberable, :omniauthable, omniauth_providers: [:developer]
  else
    devise :rememberable, :omniauthable, omniauth_providers: [:exporting_is_great]
  end

  has_many :enquiries, -> { order(:created_at) }, dependent: :nullify, inverse_of: :user
  has_many :subscriptions, dependent: :destroy

  validates :email, presence: true
  validates :uid, uniqueness: { scope: :provider }, allow_nil: true

  def self.from_omniauth(auth)
    stub_user = find_by(uid: nil, provider: nil, email: auth.info.email.downcase)

    if stub_user.present?
      stub_user.update!(provider: auth.provider, uid: auth.uid)
      return stub_user
    end

    user = where(uid: auth.uid, provider: auth.provider).first_or_create
    user.update!(email: auth.info.email) if user.email != auth.info.email
    user
  end

  def saved_enquiry_data?
    enquiries.any?
  end

  def stub?
    uid.nil? && provider.nil?
  end
end
