class CreateAlbums < ActiveRecord::Migration[8.0]
  def change
    create_table :albums do |t|
      t.string :title
      t.string :artist
      t.integer :release_year
      t.string :genre
      t.integer :rating
      t.boolean :availability

      t.timestamps
    end
  end
end
