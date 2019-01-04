class AddFeaturedToSectors < ActiveRecord::Migration[5.2]
  def change
    add_column :sectors, :featured, :boolean
    add_column :sectors, :featured_order, :integer
    Sector.find_by_slug('creative-media').try(    :update, featured: true, featured_order: 1)
    Sector.find_by_slug('education-training').try(:update, featured: true, featured_order: 2)
    Sector.find_by_slug('food-drink').try(        :update, featured: true, featured_order: 3)
    Sector.find_by_slug('oil-gas').try(           :update, featured: true, featured_order: 4)
    Sector.find_by_slug('security').try(          :update, featured: true, featured_order: 5)
    Sector.find_by_slug('retail-and-luxury').try( :update, featured: true, featured_order: 6)
  end
end
