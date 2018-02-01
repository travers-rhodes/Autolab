class AnnsPointToScores < ActiveRecord::Migration
  def change
    remove_column :scores, :annotation_id
    add_column :annotations, :score_id, :integer
  end
end
