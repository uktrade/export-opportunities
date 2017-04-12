class OpportunityVersion < PaperTrail::Version
  self.table_name = :opportunity_versions
  self.sequence_name = :opportunity_versions_id_seq

  def blame
    Editor.find_by(id: whodunnit) || Editor.new(name: 'An administrator')
  end
end
