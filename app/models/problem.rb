##
# An Assessment can have many Problems, each one creates a score for each Submission
# for the Assessment.
#
class Problem < ActiveRecord::Base
  trim_field :name

  # don't need :dependent => :destroy as of 2/18/13
  has_many :scores, dependent: :delete_all
  belongs_to :assessment, touch: true
  has_many :annotations

  validates :name, presence: true
  validates_associated :assessment

  acts_as_notifiable :users,
    # Notification targets as :targets is a necessary option
    # Set to notify to author and users commented to the article, except comment owner self
    targets: ->(problem, key) {
      problem.assessment.course.course_user_data.collect {|cud| cud.user}
    }

  after_save -> { assessment.dump_yaml }

  SERIALIZABLE = Set.new %w(name description max_score optional)
  def serialize
    Utilities.serializable attributes, SERIALIZABLE
  end

  def self.deserialize_list(assessment, problems)
    problems.map { |p| assessment.problems.create(p) }
  end
end
