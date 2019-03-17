class EnableHstoreExtension < ActiveRecord::Migration[5.2]
  def change
    def change
      enable_extension 'hstore'
    end
  end
end
