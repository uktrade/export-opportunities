class AddValuesToSupplierPreference < ActiveRecord::Migration[5.2]
  def up
    SupplierPreference.delete_all
    s1 = SupplierPreference.new(id: 1, slug:'manufacturers', name:'manufacturers')
    s2 = SupplierPreference.new(id: 2, slug:'wholesalers', name:'wholesalers')
    s3 = SupplierPreference.new(id: 3, slug:'distributors', name:'distributors')
    s4 = SupplierPreference.new(id: 4, slug:'agents', name:'agents')
    s5 = SupplierPreference.new(id: 5, slug:'consultants', name:'consultants')

    s1.save!
    s2.save!
    s3.save!
    s4.save!
    s5.save!
  end

  def down
    SupplierPreference.delete_all
  end
end
