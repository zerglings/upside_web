# == Schema Information
# Schema version: 20090728042053
#
# Table name: warning_flags
#
#  id           :integer         not null, primary key
#  subject_id   :integer(8)
#  subject_type :string(64)
#  severity     :integer(1)      not null
#  description  :string(256)     not null
#  source_file  :string(256)     not null
#  source_line  :integer(4)      not null
#  stack        :string(65536)   not null
#  created_at   :datetime
#

class WarningFlag < ActiveRecord::Base
  # The subject of the warning (ex: a portfolio, a user account, a trade).
  belongs_to :subject, :polymorphic => true
  
  # The flag's seriousness, ranging from 0 onward.
  #
  # Warning flags should be addressed in order of seriousness.
  validates_numericality_of :severity, :only_integer => true,
                            :greater_than_or_equal_to => 0, :allow_nil => false

  # A human-readable description. Equivalent to an exception string. 
  validates_length_of :description, :in => 1..256, :allow_nil => false

  # The path to the file where the flag was raised.
  validates_length_of :source_file, :in => 1..256, :allow_nil => false
      
  # The source line for the file where the flag was raised. 
  validates_numericality_of :source_line, :only_integer => true,
                            :greater_than => 0, :allow_nil => false
      
  # A stack trace to the place that raised the warning flag.
  #
  # The stack trace will always be a YAML-serialized array.
  serialize :stack
  validates_presence_of :stack


  # An event that may lead to site instability.
  def self.fatal(subject, description, extra_skip_frames = 0)
    self.raise subject, 0, description, 2 + extra_skip_frames
  end

  # Serious cheats that may spoil the game for everyone.
  def self.major(subject, description, extra_skip_frames = 0)
    self.raise subect, 1, description, 2 + extra_skip_frames
  end

  # Piracy and minor cheats.
  def self.minor(subject, description, extra_skip_frames = 0)
    self.raise subject, 2, description, 2 + extra_skip_frames
  end
  
  # Raises a warning flag.
  #
  # This should be the only code path adding warning flags to the database.
  #
  # Args:
  #     subject:: the warning cause -- must be a saved ActiveRecord model
  #     severity:: 
  #     description::
  #     _skip_frames:: used internally by the other flag-raising methods
  def self.raise(subject, severity, description, _skip_frames = 1)
    stack = Kernel.caller _skip_frames
    source_file, source_line = stack.first.split ':'
    
    self.create :subject => subject, :severity => severity,
                :description => description, :stack => stack,
                :source_file => source_file, :source_line => source_line.to_i
  end
end
