class ChangeOpportunityTypes < ActiveRecord::Migration[5.2]
  def up
    Type.delete_all
    t1 = Type.new(id: 1, slug: "aid-funded-business", name: "Aid Funded Business")
    t2 = Type.new(id: 2, slug: "private-sector", name: "Private Sector")
    t3 = Type.new(id: 3, slug: "public-sector", name: "Public Sector")
    t4 = Type.new(id: 4, slug: "nato", name: "NATO")
    t5 = Type.new(id: 5, slug: "world-bank", name: "World Bank")
    t1.save!
    t2.save!
    t3.save!
    t4.save!
    t5.save!
  end

  def down
    Type.delete_all
    t1 = Type.new(id: 1, slug: "aid-funded-business", name: "Aid Funded Business")
    t2 = Type.new(id: 2, slug: "private-sector", name: "Private Sector")
    t3 = Type.new(id: 3, slug: "public-sector", name: "Public Sector")
    t1.save!
    t2.save!
    t3.save!
  end
end
