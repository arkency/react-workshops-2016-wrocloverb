class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name, null: false
      t.string :host, null: false
      t.text :description, default: "", null: false
      t.timestamps
    end
  end
end
