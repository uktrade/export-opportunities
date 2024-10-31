class CreateCustomerSatisfactionFeedback < ActiveRecord::Migration[6.1]
  def change
    create_table :csat_feedback do |t|
      t.string :url
      t.string :user_journey, default: 'OPPORTUNITY'
      t.string :satisfaction_rating
      t.string :experienced_issues, array: true, default: []
      t.string :other_detail
      t.string :likelihood_of_return
      t.text   :service_improvements_feedback

      t.timestamps
    end
  end
end
