class ChangeOpportunityValueSlugs < ActiveRecord::Migration[5.2]
  def change
    v1 = Value.where(slug: '100k').first
    v1.slug = '4'
    v1.save!

    v2 = Value.where(slug: '10k').first
    v2.slug = '2'
    v2.save!

    v3 = Value.where(slug: 'unknown').first
    v3.name ='to be confirmed'
    v3.slug = '0'
    v3.save!

    v4 = Value.where(slug: '1m').first
    v4.slug = '6'
    v4.save!

    v5 = Value.where(slug: '5m').first
    v5.slug = '8'
    v5.save!

    v6 = Value.where(slug: '500m').first
    v6.slug = '9'
    v6.save!
  end
end
