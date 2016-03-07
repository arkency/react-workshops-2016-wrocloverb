class AddTimeInMinutesToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.integer :time_in_minutes, null: false
    end
  end
end
