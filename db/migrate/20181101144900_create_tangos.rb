class CreateTangos < ActiveRecord::Migration
  def change
    create_table :tangos do |t|
      t.string :host
      t.string :port
      t.integer :timeout,   default: 15
      t.integer :max_dead_jobs, default: 500
      t.integer :def_dead_jobs, default: 15
      t.string :key
      t.boolean :use_polling,  default: false

      t.timestamps null: false
    end
  end
end
