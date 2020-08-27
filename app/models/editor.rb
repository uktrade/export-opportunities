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
    find_or_create_by(email: auth.info.email) do |editor|
      editor.uid = auth.uid
      editor.provider = auth.provider
      editor.email = auth.info.email
      editor.name = "#{auth.info.first_name} #{auth.info.last_name}".strip
    end
  end

  def staff?
    uploader? || publisher? || administrator? || previewer?
  end

  def deactivated?
    deactivated_at.present?
  end
end
