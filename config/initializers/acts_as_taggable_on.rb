# Code smell: maybe it will be better to contribute to acrs_as_taggable_on project here.
module ActsAsTaggableOn
  class Tag < ::ActiveRecord::Base
    set_table_name "fat_free_crm_tags"
  end

  class Tagging < ::ActiveRecord::Base
    set_table_name "fat_free_crm_taggings"
  end
end