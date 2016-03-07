class AddEventsConferenceForeignKey < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.uuid :conference_id, null: false
    end
  end
end
