class AddBaseScoreToProblems < ActiveRecord::Migration
  def change
    add_column :problems, :base_score, :integer, limit: 4
  end
end
