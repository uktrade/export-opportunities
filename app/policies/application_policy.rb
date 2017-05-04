class ApplicationPolicy
  attr_reader :editor, :record

  def initialize(editor, record)
    @editor = editor
    @record = record
  end

  def never_allow
    false
  end

  def editor_is_admin_or_publisher?
    @editor.administrator? || @editor.publisher?
  end

  def editor_is_admin_or_publisher_or_reviewer?
    editor_is_admin_or_publisher? || @editor.reviewer?
  end

  alias index? never_allow
  alias show? never_allow
  alias create? never_allow
  alias new? never_allow
  alias update? never_allow
  alias edit? never_allow
  alias destroy? never_allow
  alias user editor
end
