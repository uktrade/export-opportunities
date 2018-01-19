# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggerOpportunitiesInsertUpdate < ActiveRecord::Migration[4.2]
  def up
    create_trigger('opportunities_after_insert_update_row_tr', generated: true, compatibility: 1)
      .on('opportunities')
      .before(:insert, :update)
      .for_each(:row)
      .nowrap(true) do
      "tsvector_update_trigger(tsv, 'pg_catalog.english', title, teaser, description);"
    end
  end

  def down
    drop_trigger('opportunities_after_insert_update_row_tr', 'opportunities', generated: true)
  end
end
