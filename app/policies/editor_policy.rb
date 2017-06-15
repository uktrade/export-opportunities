class EditorPolicy < ApplicationPolicy
  def administrator?
    @editor.role == 'administrator'
  end

  # draft state is only visible to uploaders/previewers
  def draft_view_state?
    @editor.role == 'uploader' || @editor.role == 'previewer'
  end

  alias edit? administrator?
  alias update? administrator?
  alias index? administrator?
  alias show? administrator?
  alias destroy? administrator?
  alias reactivate? administrator?
  alias new? administrator?
  alias create? administrator?
end
