class CreateReportAudit
  def call(editor, action, params)
    report_audit = ReportAudit.new

    report_audit.editor = editor
    report_audit.action = action
    report_audit.params = params

    report_audit.save!
  end
end
