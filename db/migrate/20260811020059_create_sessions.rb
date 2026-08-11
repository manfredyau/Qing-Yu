class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :sessionable, polymorphic: true, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
