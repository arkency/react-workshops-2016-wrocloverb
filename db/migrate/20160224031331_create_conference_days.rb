class CreateConferenceDays < ActiveRecord::Migration
  def change
    create_table :conference_days, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :label, null: false
      t.datetime :from, null: false
      t.datetime :to, null: false

      t.uuid :conference_id, null: false

      t.timestamps null: false
    end
  end
end
