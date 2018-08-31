class ChangeOpportunityValues < ActiveRecord::Migration[5.1]
  def up
    Value.delete_all
    v3 = Value.new(id: 3, slug:'unknown', name:'Value unknown')
    v3.save!
    v2 = Value.new(id: 2, slug:'10k', name:'Less than 100K')
    v2.save!
    v1 = Value.new(id: 1, slug:'100k', name:'More than 100K')
    v1.save!

    v1 = Value.where(slug: '100k').first
    v1.name = '£100k-1m'
    v1.save!
    v2 = Value.where(slug: '10k').first
    v2.name = '£0-100k'
    v2.save!
    v3 = Value.where(slug: 'unknown').first
    v3.name = 'unknown'
    v3.save!
    v4 = Value.new(id:4, slug: '1m', name: '£1m-5m')
    v4.save!
    v5 = Value.new(id:5, slug: '5m', name: '£5m-50m')
    v5.save!
    v6 = Value.new(id:6, slug: '500m', name: 'more than £50m')
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
