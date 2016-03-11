class CreateConferenceDays < ActiveRecord::Migration
  def change
    create_table :conference_days, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :label, null: false
      t.datetime :from, null: false
      t.datetime :to, null: false

      t.uuid :conference_id, null: false

      t.timestamps null: false
    end
  end
end
