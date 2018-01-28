class AddAutogradedFieldToScores < ActiveRecord::Migration
  def change
    add_column :scores, :annotation_id, :integer
  end
end
