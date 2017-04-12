class AddFeedbackOptOuts < ActiveRecord::Migration
  def change
    create_table :feedback_opt_outs do |t|
      t.string :email, null: false, unique: true
      t.timestamps
    end

    add_index :feedback_opt_outs, :email, unique: true
  end
end
