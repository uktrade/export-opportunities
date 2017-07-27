class CreateReportAudit
  def call(editor_email, action, params)
    report_audit = ReportAudit.new
    editor = Editor.find_by_email(editor_email)
    report_audit.editor = editor
    report_audit.action = action
    report_audit.params = params

    report_audit.save!
  end
end
