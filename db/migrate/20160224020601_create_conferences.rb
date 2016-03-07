class CreateConferences < ActiveRecord::Migration
  def change
    create_table :conferences, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
