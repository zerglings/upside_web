class CreateConfigVariables < ActiveRecord::Migration
  def self.up
    create_table :config_variables do |t|
      t.string :name, :limit => 64, :null => false
      t.integer :instance, :limit => 4, :null => false
      t.string :value, :limit => 1024, :null => false

      t.datetime :updated_at
    end
    # Find a variable based on name and instance number.
    add_index :config_variables, [:name, :instance], :unique => true
  end

  def self.down
    remove_index :config_variables, [:name, :instance]
    
    drop_table :config_variables
  end
end
