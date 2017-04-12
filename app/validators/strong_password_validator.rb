class StrongPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, password)
    record.errors[attribute] << I18n.t('errors.guessable_password') if guessable_password?(password)
  end

  private

  def guessable_password?(password)
    return false unless password

    PasswordChecker.new(banned_passwords).matches?(password) ||
      PasswordPrefixChecker.new.matches?(password)
  end

  def banned_passwords
    PasswordBlacklistLoader.new.load_passwords || []
  end
end

# Responsible for checking whether a password is in a list of banned passwords
class PasswordChecker
  def initialize(banned_passwords)
    @banned_passwords = banned_passwords
  end

  def matches?(password)
    @banned_passwords.any? { |pwd| case_insensitive_match?(password, pwd) }
  end

  private

  def case_insensitive_match?(string1, string2)
    string1.casecmp(string2).zero?
  end
end

# Responsible for checking whether a password matches any of a list of banned prefixes
class PasswordPrefixChecker
  def initialize(banned_prefixes = BANNED_PREFIXES)
    @banned_prefixes = banned_prefixes
  end

  def matches?(password)
    @banned_prefixes.any? { |prefix| password.downcase.start_with? prefix }
  end

  BANNED_PREFIXES = %w(
    password
    ilove
    12345
  ).freeze
end

# Responsible for loading in a list of passwords from a file
class PasswordBlacklistLoader
  def initialize
    @blacklist_file_path = "#{Rails.root}/config/banned_passwords.yml"
  end

  def load_passwords
    YAML.load_file(@blacklist_file_path)
  end
end
