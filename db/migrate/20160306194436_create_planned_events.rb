class CreatePlannedEvents < ActiveRecord::Migration
  def change
    create_table :planned_events, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.uuid :conference_day_id, null: false
      t.uuid :event_id, null: false
      t.datetime :start, null: false
      t.timestamps
    end

    add_index :planned_events, [:conference_day_id, :event_id], unique: true
  end
end
