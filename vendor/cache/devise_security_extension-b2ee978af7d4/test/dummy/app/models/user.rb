class User < ActiveRecord::Base
  devise :database_authenticatable, :password_archivable, :lockable,
         :paranoid_verification, :password_expirable,
         :security_questionable
end
