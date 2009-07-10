class Bioentry < ActiveRecord::Base
  set_table_name "bioentry"
  set_primary_key "bioentry_id" 

  belongs_to :biodatabase, 
             :class_name => "Biodatabase",
             :foreign_key => "biodatabase_id"

  has_many :element,
           :class_name => "Element",
           :foreign_key => "element_id"
end
