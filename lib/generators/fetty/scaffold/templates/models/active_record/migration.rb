class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %> do |t|
    <%- for attribute in model_attributes -%>
      t.<%= attribute.type %> :<%= attribute.name %>
    <%- end -%>
    <%- if options.timestamps -%>
      t.timestamps
    <%- end -%>
    end
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
