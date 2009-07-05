class CreateWarningFlags < ActiveRecord::Migration
  def self.up
    create_table :warning_flags do |t|
      t.integer :subject_id, :limit => 8, :null => true
      t.string :subject_type, :limit => 64, :null => true
      t.integer :severity, :limit => 1, :null => false
      t.string :description, :limit => 256, :null => false
      t.string :source_file, :limit => 256, :null => false
      t.integer :source_line, :limit => 4, :null => false
      t.string :stack, :limit => 64.kilobytes, :null => false

      t.datetime :created_at
    end
    # Aggregate warnings by source location.
    add_index :warning_flags, [:source_file, :source_line], :unique => false,
                                                            :null => false
    # Aggregate warnings by severity, then drill down by source location.
    add_index :warning_flags, [:severity, :source_file, :source_line],
                              :unique => false, :null => false
    # Aggregate warnings by their cause.
    add_index :warning_flags, [:subject_type, :subject_id], :unique => false,
                                                            :null => true
  end

  def self.down    
    remove_index :warning_flags, [:source_file, :source_line]
    remove_index :warning_flags, [:severity, :source_file, :source_line]
    remove_index :warning_flags, [:subject_type, :subject_id]
    drop_table :warning_flags
  end
end
