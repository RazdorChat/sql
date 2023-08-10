-- Clean up primary keys

START TRANSACTION;
ALTER TABLE users DROP PRIMARY KEY, ADD PRIMARY KEY (id);
ALTER TABLE roles MODIFY guildID bigint unsigned NOT NULL,
	DROP PRIMARY KEY, ADD PRIMARY KEY (id),
	ADD FOREIGN KEY (guildID) REFERENCES guilds(id);
ALTER TABLE rolePermissions MODIFY guildID bigint unsigned NOT NULL,
	MODIFY roleID bigint unsigned NOT NULL,
	ADD INDEX (guildID), -- Needed by FOREIGN KEY (guildID) to remove dependence on PK
	DROP PRIMARY KEY, ADD PRIMARY KEY (roleID);
ALTER TABLE guilds MODIFY owner_id bigint unsigned,
	ADD FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL;
COMMIT;
