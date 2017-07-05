class Editor < ActiveRecord::Base
  include DeviseUserMethods
  belongs_to :service_provider
  has_many :opportunities, foreign_key: 'author_id'
  has_many :enquiry_responses

  has_many :enquiry_responses
  enum role: { uploader: 1, publisher: 2, previewer: 3, administrator: 4 }

  devise :database_authenticatable,
    :recoverable, :rememberable, :trackable, :validatable,
    :registerable, :confirmable, :async, :lockable

  validates :password, strong_password: true, if: :password_required?

  def valid_password?(password)
    super(password)
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def staff?
    uploader? || publisher? || administrator? || previewer?
  end

  def deactivated?
    deactivated_at.present?
  end
end
