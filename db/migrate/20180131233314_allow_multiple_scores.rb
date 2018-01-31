class AllowMultipleScores < ActiveRecord::Migration
  def change
    remove_index :scores, name: "problem_submission_unique"
    add_index "scores",["problem_id","submission_id"],:name=>"problem_submission_unique",:unique=>false
  end
end
