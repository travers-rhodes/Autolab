class AddTangoToAutograders < ActiveRecord::Migration
  def change
    add_reference :tangos, :autograder, index: true, foreign_key: true
  end
end
