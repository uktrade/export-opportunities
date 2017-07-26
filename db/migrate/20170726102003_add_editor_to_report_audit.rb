class AddEditorToReportAudit < ActiveRecord::Migration
  create_table :report_audits do |t|
    t.string :action, null: false
    t.belongs_to :editor
    t.json :params
    t.timestamps
  end
end
