# frozen_string_literal: true

class Editor < ApplicationRecord # :nodoc:
  include DeviseUserMethods
  belongs_to :service_provider
  has_many :opportunities,
           foreign_key: 'author_id',
           dependent: :nullify, inverse_of: :editor
  has_many :enquiry_responses, dependent: :nullify
  has_many :report_audits, dependent: :destroy

  enum role: { uploader: 1, publisher: 2, previewer: 3, administrator: 4 }

  def self.from_omniauth(auth)
    editor = find_or_create_by(email: auth.info.email) do |e|
      e.uid      = auth.uid
      e.provider = auth.provider
      e.email    = auth.info.email
      e.name     = "#{auth.info.first_name} #{auth.info.last_name}".strip
    end

    editor.update_uid!(auth.uid)
  end

  def staff?
    uploader? || publisher? || administrator? || previewer?
  end

  def deactivated?
    deactivated_at.present?
  end

  def update_uid!(auth_uid)
    update_attribute(:uid, auth_uid) if uid.blank?

    self
  end
end
