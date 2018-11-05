class Tango < ActiveRecord::Base
  belongs_to :autograder
  
  validates :host, :port, :key, presence: true
end
