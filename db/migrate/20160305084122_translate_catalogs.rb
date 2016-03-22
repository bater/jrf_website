class TranslateCatalogs < ActiveRecord::Migration
  def up
  	Catalog.create_translation_table!({
                                      :name => :string
                                   }, {
                                       :migrate_data => true
                                   })
  end
  def down
    Catalog.drop_translation_table! :migrate_data => true
  end
end
