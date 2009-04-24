# == Schema Information
# Schema version: 20090424025419
#
# Table name: config_variables
#
#  id         :integer(4)      not null, primary key
#  name       :string(64)      not null
#  instance   :integer(4)      not null
#  value      :string(1024)    not null
#  updated_at :datetime
#

class ConfigVariable < ActiveRecord::Base
  # The variable name.
  validates_length_of :name, :in => 1..64, :allow_nil => false
  
  # The variable instance number. Convenient when configuration variables need
  # different values across different shards of some process. Defaults to 0.
  validates_numericality_of :instance, :only_integer => true,
                            :greater_than_or_equal_to => 0, :allow_nil => false

  # The variable's value. Stored serialized in YAML.
  serialize :value

  validates_uniqueness_of :instance, :scope => :name

  # Retrieves the value of a configuration variable.
  def self.fetch(name, default = nil)
    if name.respond_to? :to_str
      instance = 0
    else
      name, instance = *name
    end
    
    var = ConfigVariable.find(:first,
                              :conditions => { :name => name,
                                               :instance => instance})
    var ? var.value : default    
  end
  
  # Sets the value of a configuration variable.
  def self.store(name, value)
    if name.respond_to? :to_str
      instance = 0
    else
      name, instance = *name
    end

    var = ConfigVariable.find(:first,
                              :conditions => { :name => name,
                                               :instance => instance})
    var ||= ConfigVariable.new :name => name, :instance => instance
    var.value = value
    var.save!
  end
  
  def self.[](name)
    fetch name, nil
  end
  
  def self.[]=(name, value)
    store name, value
  end
end
