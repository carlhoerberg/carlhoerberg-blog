
migration 1, :title_and_slug_255_chars do
	up do
		modify_table :posts do
			change_column :title, 'varchar(255)'
			change_column :slug, 'varchar(255)'
		end
	end
end

