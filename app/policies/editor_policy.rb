class EditorPolicy < ApplicationPolicy
  def administrator?
    @editor.role == 'administrator'
  end

  alias edit? administrator?
  alias update? administrator?
  alias index? administrator?
  alias show? administrator?
  alias destroy? administrator?
  alias new? administrator?
  alias create? administrator?
end
