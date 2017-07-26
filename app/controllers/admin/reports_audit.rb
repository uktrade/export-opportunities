module Admin
  class ReportsAuditController < BaseController
    private

    def report_audit_params
      # params.permit!
      params.require(:report_audit).permit(:editor, :action, :params)
    end
  end
end
