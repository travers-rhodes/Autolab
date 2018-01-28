class AddAutogradedFieldToScores < ActiveRecord::Migration
  def change
    add_column :scores, :autograded, :boolean, default: false
  end
end
