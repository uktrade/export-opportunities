class ChangeOpportunityValues < ActiveRecord::Migration[5.1]
  def up
    v1 = Value.find(1)
    v1.slug = '100k-1m'
    v1.name = '£100k-1m'
    v1.save!
    v2 = Value.find(2)
    v2.name = '£0-100k'
    v2.save!
    v3 = Value.find(3)
    v3.name = 'unknown'
    v3.save!
    v4 = Value.new(id:4, slug: '£1m-5m', name: '£1m-5m')
    v4.save!
    v5 = Value.new(id:5, slug: '£5m-50m', name: '£5m-50m')
    v5.save!
    v6 = Value.new(id:6, slug: 'more than £50m', name: 'more than £50m')
    v6.save!

  end

  def down
    Value.delete_all
    v3 = Value.new(id: 3, slug:'unknown', name:'Value unknown')
    v3.save!
    v2 = Value.new(id: 2, slug:'10k', name:'Less than 100K')
    v2.save!
    v1 = Value.new(id: 1, slug:'100k', name:'More than 100K')
    v1.save!
  end
end
